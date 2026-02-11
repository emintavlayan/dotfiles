-- ~/.config/nvim/lua/custom/dynafocus.lua
--
-- DynaFocus: Outline + structural navigation + view folds + focus editing
-- files that use:
--   doc <title>
--   COL <title>
--
-- All functionality lives in this one file and is loaded by lazy.nvim.

return {
  {
    name = "dyna-doc-local",
    -- Use your config directory as a "local plugin root" so this shows up in :Lazy.
    -- This avoids any extra directories or repos.
    dir = vim.fn.stdpath("config"),
    lazy = false,

    config = function()
      ---------------------------------------------------------------------------
      -- Configuration
      ---------------------------------------------------------------------------
      local cfg = {
        doc_prefix = "doc",
        col_prefix = "COL",

        outline = {
          width_factor = 0.28,
          min_width = 26,
          max_width = 60,
          side = "left", -- "left" or "right"
        },

        focus = {
          as_float = true,
          width_factor = 0.78,
          height_factor = 0.78,
          border = "rounded",
          lock_source_buffer = false,  -- set true if you want the source buffer read-only during focus
          apply_view_on_open = true,   -- apply doc/COL view automatically inside the focus buffer
        },

        notify = { title = "DynaDoc" },
      }

      -- Optional user override (advanced): vim.g.dyna_doc_config = { ... }
      if type(vim.g.dyna_doc_config) == "table" then
        cfg = vim.tbl_deep_extend("force", cfg, vim.g.dyna_doc_config)
      end

      ---------------------------------------------------------------------------
      -- Utilities
      ---------------------------------------------------------------------------
      local function notify(msg, level)
        vim.notify(msg, level or vim.log.levels.INFO, cfg.notify)
      end

      local function indent_step(bufnr)
        local sw = vim.bo[bufnr].shiftwidth
        if sw == 0 then sw = vim.bo[bufnr].tabstop end
        if sw == 0 then sw = 4 end
        return sw
      end

      local function count_indent(line, step)
        local prefix = line:match("^[\t ]*") or ""
        local n = 0
        for i = 1, #prefix do
          local c = prefix:sub(i, i)
          if c == "\t" then
            n = n + step
          else
            n = n + 1
          end
        end
        return n, prefix
      end

      local function classify_line(line, step)
        local ind, prefix = count_indent(line, step)
        local trimmed = line:sub(#prefix + 1)

        if trimmed == cfg.doc_prefix or trimmed:match("^" .. cfg.doc_prefix .. "%s+") then
          return { kind = "doc", indent = ind, text = trimmed }
        end

        if trimmed == cfg.col_prefix or trimmed:match("^" .. cfg.col_prefix .. "%s+") then
          return { kind = "col", indent = ind, text = trimmed }
        end

        return nil
      end

      local function buf_lines(bufnr)
        return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      end

      local function is_win_valid(win)
        return win and vim.api.nvim_win_is_valid(win)
      end

      local function is_buf_valid(buf)
        return buf and vim.api.nvim_buf_is_valid(buf)
      end

      local function with_win(win, fn)
        local cur = vim.api.nvim_get_current_win()
        if cur == win then
          return fn()
        end
        vim.api.nvim_set_current_win(win)
        local ok, res = pcall(fn)
        vim.api.nvim_set_current_win(cur)
        if not ok then error(res) end
        return res
      end

      local function jump_to_line(win, lnum)
        if not is_win_valid(win) then return end
        with_win(win, function()
          vim.api.nvim_win_set_cursor(win, { lnum, 0 })
          vim.cmd("normal! zt") -- header at top
          vim.cmd("normal! zs") -- horizontal align left
        end)
      end

      ---------------------------------------------------------------------------
      -- Tree / section math
      ---------------------------------------------------------------------------
      local function find_nearest_header(lines, step, from_lnum)
        for l = from_lnum, 1, -1 do
          local info = classify_line(lines[l], step)
          if info then
            info.lnum = l
            return info
          end
        end
        return nil
      end

      local function find_section_end(lines, step, header_lnum)
        local h = classify_line(lines[header_lnum], step)
        if not h then return nil end
        local base = h.indent
        for l = header_lnum + 1, #lines do
          local info = classify_line(lines[l], step)
          if info and info.indent <= base then
            return l - 1
          end
        end
        return #lines
      end

      local function find_parent_header(lines, step, header_info)
        -- Parent is the nearest header above with a smaller indent.
        for l = header_info.lnum - 1, 1, -1 do
          local info = classify_line(lines[l], step)
          if info and info.indent < header_info.indent then
            info.lnum = l
            return info
          end
        end
        return nil
      end

      local function find_first_child(lines, step, header_info, want_kind)
        local section_end = find_section_end(lines, step, header_info.lnum)
        if not section_end then return nil end
        local want_indent = header_info.indent + step

        for l = header_info.lnum + 1, section_end do
          local info = classify_line(lines[l], step)
          if info and info.kind == want_kind and info.indent == want_indent then
            info.lnum = l
            return info
          end
        end
        return nil
      end

      ---------------------------------------------------------------------------
      -- View (fold) mode
      --
      -- Uses manual folds and standard fold commands:
      -- - :{range}fold to create closed folds
      -- - zE to eliminate folds
      -- - zM to close all folds
      -- - zv to open enough folds to see cursor line
      ---------------------------------------------------------------------------
      local view_state = {} -- keyed by winid

      local function save_view_prev(win)
        if view_state[win] and view_state[win].prev then return end
        view_state[win] = view_state[win] or {}
        view_state[win].prev = {
          foldmethod = vim.wo[win].foldmethod,
          foldexpr = vim.wo[win].foldexpr,
          foldenable = vim.wo[win].foldenable,
          foldlevel = vim.wo[win].foldlevel,
        }
      end

      local function clear_folds_in_window(win)
        with_win(win, function()
          vim.wo.foldmethod = "manual"
          vim.wo.foldenable = true
          pcall(vim.cmd, "silent! normal! zE") -- eliminate folds in window
        end)
      end

      local function restore_view(win)
        local st = view_state[win]
        with_win(win, function()
          -- Make sure folds are gone
          vim.wo.foldmethod = "manual"
          vim.wo.foldenable = true
          pcall(vim.cmd, "silent! normal! zE")

          -- Restore previous settings if we captured them
          if st and st.prev then
            vim.wo.foldmethod = st.prev.foldmethod
            vim.wo.foldexpr = st.prev.foldexpr
            vim.wo.foldenable = st.prev.foldenable
            vim.wo.foldlevel = st.prev.foldlevel
          end
        end)
        view_state[win] = nil
      end

      local function create_fold_range(start_lnum, end_lnum)
        if not start_lnum or not end_lnum then return end
        if start_lnum >= end_lnum then return end
        pcall(vim.cmd, string.format("silent! %d,%dfold", start_lnum, end_lnum))
      end

      local function apply_doc_view(win, bufnr, header_info)
        save_view_prev(win)
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)
        local end_lnum = find_section_end(lines, step, header_info.lnum)
        if not end_lnum then return end

        with_win(win, function()
          vim.wo.foldmethod = "manual"
          vim.wo.foldenable = true
          pcall(vim.cmd, "silent! normal! zE")

          -- Fold each direct child COL subtree (but keep COL headings visible)
          local want_indent = header_info.indent + step
          local l = header_info.lnum + 1
          while l <= end_lnum do
            local info = classify_line(lines[l], step)
            if info and info.kind == "col" and info.indent == want_indent then
              local col_end = find_section_end(lines, step, l) or end_lnum
              if col_end > end_lnum then col_end = end_lnum end
              create_fold_range(l + 1, col_end)
              l = col_end + 1
            else
              l = l + 1
            end
          end

          pcall(vim.cmd, "silent! normal! zM") -- close all folds
          pcall(vim.cmd, "silent! normal! zv") -- ensure cursor line visible
        end)
      end

      local function apply_col_view(win, bufnr, header_info)
        save_view_prev(win)
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)
        local end_lnum = find_section_end(lines, step, header_info.lnum)
        if not end_lnum then return end

        with_win(win, function()
          vim.wo.foldmethod = "manual"
          vim.wo.foldenable = true
          pcall(vim.cmd, "silent! normal! zE")

          -- Fold each direct child doc subtree (but keep doc headings visible)
          local want_indent = header_info.indent + step
          local l = header_info.lnum + 1
          while l <= end_lnum do
            local info = classify_line(lines[l], step)
            if info and info.kind == "doc" and info.indent == want_indent then
              local doc_end = find_section_end(lines, step, l) or end_lnum
              if doc_end > end_lnum then doc_end = end_lnum end
              create_fold_range(l + 1, doc_end)
              l = doc_end + 1
            else
              l = l + 1
            end
          end

          pcall(vim.cmd, "silent! normal! zM")
          pcall(vim.cmd, "silent! normal! zv")
        end)
      end

      local function apply_view_auto()
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)

        local cur_lnum = vim.api.nvim_win_get_cursor(win)[1]
        local h = find_nearest_header(lines, step, cur_lnum)
        if not h then
          notify("No 'doc' or 'COL' header found above cursor.", vim.log.levels.WARN)
          return
        end

        if h.kind == "doc" then
          apply_doc_view(win, bufnr, h)
        else
          apply_col_view(win, bufnr, h)
        end
      end

      ---------------------------------------------------------------------------
      -- Outline window
      ---------------------------------------------------------------------------
      local function outline_width()
        local w = math.floor(vim.o.columns * cfg.outline.width_factor)
        if w < cfg.outline.min_width then w = cfg.outline.min_width end
        if w > cfg.outline.max_width then w = cfg.outline.max_width end
        return w
      end

      local function open_outline()
        local src_win = vim.api.nvim_get_current_win()
        local src_buf = vim.api.nvim_get_current_buf()

        local step = indent_step(src_buf)
        local lines = buf_lines(src_buf)

        local items = {}
        for l = 1, #lines do
          local info = classify_line(lines[l], step)
          if info then
            local depth = math.floor(info.indent / step)
            local prefix = string.rep("  ", depth)
            table.insert(items, { display = prefix .. info.text, target_lnum = l })
          end
        end

        if #items == 0 then
          notify("No outline items (no 'doc'/'COL' lines) in this buffer.", vim.log.levels.WARN)
          return
        end

        local obuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(obuf, "DynaDoc://outline")
        vim.bo[obuf].buftype = "nofile"
        vim.bo[obuf].bufhidden = "wipe"
        vim.bo[obuf].swapfile = false
        vim.bo[obuf].modifiable = true

        local out_lines = {}
        local map = {}
        for i, it in ipairs(items) do
          out_lines[i] = it.display
          map[i] = it.target_lnum
        end
        vim.api.nvim_buf_set_lines(obuf, 0, -1, false, out_lines)
        vim.bo[obuf].modifiable = false

        -- Open side window
        local w = outline_width()
        if cfg.outline.side == "right" then
          vim.cmd("botright vnew")
        else
          vim.cmd("topleft vnew")
        end
        local owin = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_width(owin, w)
        vim.api.nvim_win_set_buf(owin, obuf)

        vim.wo[owin].number = false
        vim.wo[owin].relativenumber = false
        vim.wo[owin].signcolumn = "no"
        vim.wo[owin].wrap = false
        vim.wo[owin].cursorline = true

        -- Buffer-local actions
        local function close_outline()
          if is_win_valid(owin) then
            vim.api.nvim_win_close(owin, true)
          end
        end

        local function jump()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          local target = map[lnum]
          if not target then return end

          close_outline()

          if is_win_valid(src_win) then
            jump_to_line(src_win, target)
          elseif is_buf_valid(src_buf) then
            vim.api.nvim_set_current_buf(src_buf)
            jump_to_line(vim.api.nvim_get_current_win(), target)
          end

          -- Apply view automatically after jump (optional but matches your intended workflow)
          apply_view_auto()
        end

        vim.keymap.set("n", "q", close_outline, { buffer = obuf, nowait = true, silent = true })
        vim.keymap.set("n", "<CR>", jump, { buffer = obuf, nowait = true, silent = true })
      end

      ---------------------------------------------------------------------------
      -- Structural navigation
      ---------------------------------------------------------------------------
      local function jump_next(kind)
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)

        local cur = vim.api.nvim_win_get_cursor(win)[1]
        for l = cur + 1, #lines do
          local info = classify_line(lines[l], step)
          if info and info.kind == kind then
            jump_to_line(win, l)
            apply_view_auto()
            return
          end
        end
        notify("No next " .. kind .. " header found.", vim.log.levels.INFO)
      end

      local function jump_prev(kind)
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)

        local cur = vim.api.nvim_win_get_cursor(win)[1]
        for l = cur - 1, 1, -1 do
          local info = classify_line(lines[l], step)
          if info and info.kind == kind then
            jump_to_line(win, l)
            apply_view_auto()
            return
          end
        end
        notify("No previous " .. kind .. " header found.", vim.log.levels.INFO)
      end

      local function go_inner()
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)

        local cur = vim.api.nvim_win_get_cursor(win)[1]
        local h = find_nearest_header(lines, step, cur)
        if not h then
          notify("No 'doc'/'COL' header found above cursor.", vim.log.levels.WARN)
          return
        end

        if h.kind == "doc" then
          local child = find_first_child(lines, step, h, "col")
          if not child then
            notify("This doc has no direct COL child.", vim.log.levels.INFO)
            return
          end
          jump_to_line(win, child.lnum)
          apply_col_view(win, bufnr, child)
        else
          local child = find_first_child(lines, step, h, "doc")
          if not child then
            notify("This COL has no direct doc child.", vim.log.levels.INFO)
            return
          end
          jump_to_line(win, child.lnum)
          apply_doc_view(win, bufnr, child)
        end
      end

      local function go_outer()
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_get_current_buf()
        local step = indent_step(bufnr)
        local lines = buf_lines(bufnr)

        local cur = vim.api.nvim_win_get_cursor(win)[1]
        local h = find_nearest_header(lines, step, cur)
        if not h then
          notify("No 'doc'/'COL' header found above cursor.", vim.log.levels.WARN)
          return
        end

        local parent = find_parent_header(lines, step, h)
        if not parent then
          notify("No parent header (already at top-level).", vim.log.levels.INFO)
          return
        end

        jump_to_line(win, parent.lnum)
        if parent.kind == "doc" then
          apply_doc_view(win, bufnr, parent)
        else
          apply_col_view(win, bufnr, parent)
        end
      end

      ---------------------------------------------------------------------------
      -- Focus editing (acwrite buffer + BufWriteCmd)
      ---------------------------------------------------------------------------
      local focus_state = {} -- keyed by focus bufnr

      local function open_focus()
        local src_win = vim.api.nvim_get_current_win()
        local src_buf = vim.api.nvim_get_current_buf()
        local step = indent_step(src_buf)
        local lines = buf_lines(src_buf)

        local cur = vim.api.nvim_win_get_cursor(src_win)[1]
        local h = find_nearest_header(lines, step, cur)
        if not h then
          notify("No 'doc'/'COL' header found above cursor; cannot focus.", vim.log.levels.WARN)
          return
        end

        local section_end = find_section_end(lines, step, h.lnum)
        if not section_end then
          notify("Could not compute section end; cannot focus.", vim.log.levels.ERROR)
          return
        end

        -- Create focus buffer
        local fbuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(fbuf, string.format("DynaDoc://focus/%d/%d-%d", src_buf, h.lnum, section_end))

        vim.bo[fbuf].buftype = "acwrite"
        vim.bo[fbuf].bufhidden = "wipe"
        vim.bo[fbuf].swapfile = false
        vim.bo[fbuf].modifiable = true
        vim.bo[fbuf].filetype = vim.bo[src_buf].filetype

        local chunk = vim.api.nvim_buf_get_lines(src_buf, h.lnum - 1, section_end, false)
        vim.api.nvim_buf_set_lines(fbuf, 0, -1, false, chunk)

        local fwin
        if cfg.focus.as_float then
          local width = math.floor(vim.o.columns * cfg.focus.width_factor)
          local height = math.floor(vim.o.lines * cfg.focus.height_factor)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)

          fwin = vim.api.nvim_open_win(fbuf, true, {
            relative = "editor",
            style = "minimal",
            border = cfg.focus.border,
            width = width,
            height = height,
            row = row,
            col = col,
          })
        else
          vim.cmd("vnew")
          fwin = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_buf(fwin, fbuf)
        end

        vim.wo[fwin].wrap = false
        vim.wo[fwin].cursorline = true

        focus_state[fbuf] = {
          src_buf = src_buf,
          src_win = src_win,
          start_lnum = h.lnum,
          end_lnum = section_end,
          src_changedtick = vim.api.nvim_buf_get_changedtick(src_buf),
          lock = {
            enabled = cfg.focus.lock_source_buffer,
            modifiable = vim.bo[src_buf].modifiable,
            readonly = vim.bo[src_buf].readonly,
          },
        }

        if cfg.focus.lock_source_buffer then
          vim.bo[src_buf].modifiable = false
          vim.bo[src_buf].readonly = true
        end

        -- Define what :write means in the focus buffer:
        vim.api.nvim_create_autocmd("BufWriteCmd", {
          buffer = fbuf,
          callback = function()
            local st = focus_state[fbuf]
            if not st or not is_buf_valid(st.src_buf) then
              notify("Focus write failed: missing source buffer.", vim.log.levels.ERROR)
              return
            end

            local now_tick = vim.api.nvim_buf_get_changedtick(st.src_buf)
            if now_tick ~= st.src_changedtick then
              notify("Warning: source buffer changed since focus opened. Writing anyway.", vim.log.levels.WARN)
            end

            local new_lines = vim.api.nvim_buf_get_lines(fbuf, 0, -1, false)
            vim.api.nvim_buf_set_lines(st.src_buf, st.start_lnum - 1, st.end_lnum, false, new_lines)

            -- Update end line in case length changed
            st.end_lnum = st.start_lnum + #new_lines - 1
            st.src_changedtick = vim.api.nvim_buf_get_changedtick(st.src_buf)

            vim.bo[fbuf].modified = false
            notify("Focus changes applied to source buffer (not written to disk).", vim.log.levels.INFO)
          end,
        })

        -- When focus buffer is wiped, restore source buffer flags if we locked them
        vim.api.nvim_create_autocmd("BufWipeout", {
          buffer = fbuf,
          once = true,
          callback = function()
            local st = focus_state[fbuf]
            if st and st.lock and st.lock.enabled and is_buf_valid(st.src_buf) then
              vim.bo[st.src_buf].modifiable = st.lock.modifiable
              vim.bo[st.src_buf].readonly = st.lock.readonly
            end
            focus_state[fbuf] = nil
          end,
        })

        -- Focus buffer key: q to close (but refuse if modified, like normal Vim behavior)
        vim.keymap.set("n", "q", function()
          if vim.bo[fbuf].modified then
            notify("Focus buffer modified. Use :w to apply, or :q! to discard.", vim.log.levels.WARN)
            return
          end
          vim.cmd("q")
        end, { buffer = fbuf, nowait = true, silent = true })

        -- Optional: apply doc/COL view inside focus buffer
        if cfg.focus.apply_view_on_open then
          apply_view_auto()
        end
      end

      ---------------------------------------------------------------------------
      -- Commands
      ---------------------------------------------------------------------------
      vim.api.nvim_create_user_command("DynaOutline", open_outline, {})
      vim.api.nvim_create_user_command("DynaView", apply_view_auto, {})
      vim.api.nvim_create_user_command("DynaRestore", function()
        restore_view(vim.api.nvim_get_current_win())
      end, {})
      vim.api.nvim_create_user_command("DynaFocus", open_focus, {})

      ---------------------------------------------------------------------------
      -- Keymaps (requested comment style)
      ---------------------------------------------------------------------------
      local map = vim.keymap.set

      -- <leader>do — [d]yna [o]utline
      map("n", "<leader>do", open_outline, { desc = "DynaDoc: open outline (doc/COL index)" })

      -- <leader>df — [d]yna [f]ocus
      map("n", "<leader>df", open_focus, { desc = "DynaDoc: focus current section (edit isolated; :w applies)" })

      -- <leader>dv — [d]yna [v]iew
      map("n", "<leader>dv", apply_view_auto, { desc = "DynaDoc: apply view folds (auto: doc or COL)" })

      -- <leader>dr — [d]yna [r]estore
      map("n", "<leader>dr", function()
        restore_view(vim.api.nvim_get_current_win())
      end, { desc = "DynaDoc: restore folds/options (clear DynaDoc view)" })

      -- <leader>ddn — [d]yna [d]oc [n]ext
      map("n", "<leader>ddn", function() jump_next("doc") end, { desc = "DynaDoc: jump to next doc header" })

      -- <leader>ddp — [d]yna [d]oc [p]revious
      map("n", "<leader>ddp", function() jump_prev("doc") end, { desc = "DynaDoc: jump to previous doc header" })

      -- <leader>dcn — [d]yna [c]ollection [n]ext
      map("n", "<leader>dcn", function() jump_next("col") end, { desc = "DynaDoc: jump to next COL header" })

      -- <leader>dcp — [d]yna [c]ollection [p]revious
      map("n", "<leader>dcp", function() jump_prev("col") end, { desc = "DynaDoc: jump to previous COL header" })

      -- <leader>di — [d]yna [i]nner
      map("n", "<leader>di", go_inner, { desc = "DynaDoc: go inner (doc→first COL, COL→first doc)" })

      -- <leader>du — [d]yna [u]p
      map("n", "<leader>du", go_outer, { desc = "DynaDoc: go outer (to parent header)" })
    end,
  },
}
