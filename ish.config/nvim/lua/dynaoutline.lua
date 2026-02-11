-- lua/dynaoutline_simple.lua
--
-- Disposable outline (projection) for doc/COL headers.
-- No folds. No parsing trees. No extmarks. Minimal state.
--
-- Workflow:
--   <leader>vi  -> open outline split containing ONLY doc/COL header lines
--   Navigate in outline
--   <CR>        -> copy current outline line, close outline, find same line in source buffer
--   q           -> close outline
--
-- Jump ergonomics:
--   After jumping back into the big buffer:
--     zt -> cursor line becomes top line
--     zs -> horizontal scroll so cursor column is at left edge

local M = {}

local function reveal_header()
  vim.cmd("normal! zt") -- cursor line at top
  vim.cmd("normal! zs") -- horizontal scroll so cursor column is leftmost
end

local function is_header(line)
  return line:match("^%s*doc%s") or line:match("^%s*COL%s")
end

function M.open_outline()
  local source_buf = vim.api.nvim_get_current_buf()

  -- Read all source lines
  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)

  -- Keep only header lines (preserve indentation exactly)
  local outline_lines = {}
  for _, line in ipairs(lines) do
    if is_header(line) then
      table.insert(outline_lines, line)
    end
  end

  -- Open vertical split for outline
  vim.cmd("vsplit")

  local outline_buf = vim.api.nvim_get_current_buf()

  -- Configure as scratch buffer
  vim.api.nvim_buf_set_option(outline_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(outline_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(outline_buf, "swapfile", false)
  vim.api.nvim_buf_set_option(outline_buf, "modifiable", true)
  vim.api.nvim_buf_set_option(outline_buf, "readonly", true)

  vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, outline_lines)
  vim.api.nvim_buf_set_option(outline_buf, "modifiable", false)

  -- Store source buffer number on this outline buffer
  vim.b.dynaoutline_source_buf = source_buf

  -- Jump key: <CR>
  vim.keymap.set("n", "<CR>", function()
    M.jump_to_source()
  end, { buffer = outline_buf, silent = true })

  -- Quit outline with q
  vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = outline_buf, silent = true })
end

function M.jump_to_source()
  local source_buf = vim.b.dynaoutline_source_buf
  if not source_buf or not vim.api.nvim_buf_is_valid(source_buf) then
    return
  end

  -- Exact outline line (including indentation)
  local line = vim.fn.getline(".")

  -- Close outline buffer
  vim.cmd("bd!")

  -- Switch back to source buffer
  vim.api.nvim_set_current_buf(source_buf)

  -- Escape search pattern safely (so special chars in titles won't break the search)
  local pat = "^" .. vim.fn.escape(line, "\\/.*$^~[]")
  
  -- Search forward (W = no wrap). This finds the exact header line in the big file.
  vim.fn.search(pat, "W")

  reveal_header()
end

function M.setup_keymaps()
  vim.keymap.set("n", "<leader>vi", function()
    M.open_outline()
  end, { silent = true, noremap = true })
end

return M

