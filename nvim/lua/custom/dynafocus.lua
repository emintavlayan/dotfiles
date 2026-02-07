-- lua/dynafocus.lua
-- Purpose:
--   Navigation + focusing for a "doc / COL" outline format inside a single large file.
--
-- Format assumptions (strict):
--   - Document headers start with:  "doc "  (lowercase 'doc' + SPACE)
--   - Collection headers start with: "COL " (uppercase 'COL' + SPACE)
--
-- You get two kinds of operations:
--   1) VIEW / NAVIGATION (no narrowing, stays in the big buffer)
--   2) FOCUS (narrowing using tkancf/narrowing-nvim + folding in the narrowed buffer)
--
-- IMPORTANT NOTE about folds:
--   We use 'foldmethod=expr' with a fold expression ('foldexpr') to decide what lines start folds.
--   Then we use normal-mode fold commands like:
--     zM  -> close ALL folds
--     zR  -> open ALL folds
--     zo  -> open one fold under cursor
--     zc  -> close one fold under cursor

local M = {}

-- -----------------------------
-- Helpers: detect current header
-- -----------------------------

-- Returns:
--   "doc" if current line starts with "doc "
--   "col" if current line starts with "COL "
--   nil   otherwise
local function current_node_type()
  local line = vim.fn.getline(".")
  if line:match("^doc%s") then
    return "doc"
  elseif line:match("^COL%s") then
    return "col"
  end
  return nil
end

-- Jump cursor backward to the nearest structural header: "doc " or "COL ".
-- Flags:
--   b -> search backward
--   W -> don't wrap around end-of-file
local function jump_to_header()
  vim.fn.search([[^\(doc\s\|COL\s\)]], "bW")
end

-- Jump forward to next doc header.
local function next_doc()
  vim.fn.search([[^doc\s]], "W")
end

-- Jump backward to previous doc header.
local function prev_doc()
  vim.fn.search([[^doc\s]], "bW")
end

-- Jump forward to next COL header.
local function next_col()
  vim.fn.search([[^COL\s]], "W")
end

-- Jump backward to previous COL header.
local function prev_col()
  vim.fn.search([[^COL\s]], "bW")
end

-- -----------------------------
-- VIEW MODE (no narrowing)
-- -----------------------------
-- These apply folds in the CURRENT buffer.

-- View as "document":
--   - fold all lines that start a collection header ("COL ")
--   - keep document body readable
local function view_doc()
  -- 'foldmethod=expr' makes Vim compute folds based on a Lua/Vimscript expression.
  vim.opt.foldmethod = "expr"

  -- foldexpr must return fold levels.
  -- Here: if a line starts with "COL ", return '1' meaning "start a fold here".
  -- Otherwise return '0' meaning "do not start a fold here".
  vim.opt.foldexpr = [[getline(v:lnum) =~ '^\\s*COL\\s' ? '1' : '0']]

  -- Close all folds (zM = "fold More", closes everything)
  vim.cmd("normal! zM") -- zM: close all folds

  -- Open all folds (zR = "fold Reduce", opens everything)
  -- We do this so the document body isn't accidentally hidden.
  -- Then the COL folds remain closed due to zM above.
  vim.cmd("normal! zR") -- zR: open all folds (then COL folds remain as defined)
end

-- View as "collection":
--   - show only doc title lines under the collection
--   - fold everything else (doc bodies)
local function view_col()
  vim.opt.foldmethod = "expr"

  -- Strategy:
  --   - Keep "doc " header lines visible (return '0' on those lines).
  --   - Everything else below them becomes folded.
  --
  -- NOTE: This is a simple heuristic that works best when you're "zoomed" mentally on a collection area.
  -- It is not trying to parse full tree indentation; it's a view tool.
  vim.opt.foldexpr = [[
    getline(v:lnum) =~ '^\\s*doc\\s' ? '0' :
    v:lnum > 1 ? '1' : '0'
  ]]

  vim.cmd("normal! zM") -- zM: close all folds
end

-- -----------------------------
-- INNER / OUTER NAVIGATION (no narrowing)
-- -----------------------------

-- "Inner" means: go down one structural step.
-- If on a doc header -> go to next collection header and render collection view.
-- If on a COL header -> go to first child doc header and render doc view.
function M.go_inner()
  jump_to_header()
  local t = current_node_type()
  if t == "doc" then
    next_col()
    -- After moving into the collection, show doc list style.
    view_col()
  elseif t == "col" then
    vim.fn.search([[^\s*doc\s]], "W")
    view_doc()
  end
end

-- "Outer" means: go up to nearest header above and render its appropriate view.
function M.go_outer()
  -- Go to previous header line.
  vim.fn.search([[^\(doc\s\|COL\s\)]], "bW")

  local t = current_node_type()
  if t == "doc" then
    view_doc()
  elseif t == "col" then
    view_col()
  end
end

-- Convenience: render current header's view (no narrowing).
function M.view_here()
  jump_to_header()
  local t = current_node_type()
  if t == "doc" then
    view_doc()
  elseif t == "col" then
    view_col()
  end
end

-- -----------------------------
-- FOCUS (narrowing + folding in narrowed buffer)
-- -----------------------------
-- We rely ONLY on documented plugin functions:
--   require("narrowing").narrow_fold()

-- Apply folding INSIDE narrowed buffer for doc focus:
--   fold all COL blocks
local function fold_cols_in_narrow()
  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = [[getline(v:lnum) =~ '^\\s*COL\\s' ? '1' : '0']]
  vim.cmd("normal! zM") -- zM: close all folds
  vim.cmd("normal! zR") -- zR: open all folds (keeps body readable; COL folds still defined)
end

-- Apply folding INSIDE narrowed buffer for collection focus:
--   show only doc header lines
local function fold_docs_in_narrow()
  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = [[
    getline(v:lnum) =~ '^\\s*doc\\s' ? '0' :
    v:lnum > 1 ? '1' : '0'
  ]]
  vim.cmd("normal! zM") -- zM: close all folds
end

-- Smart focus:
--   1) jump to nearest header above (doc or COL)
--   2) narrow that fold using narrowing-nvim
--   3) apply the correct folding inside the narrowed buffer
function M.focus_smart()
  jump_to_header()
  local t = current_node_type()
  if not t then
    return
  end

  -- Narrow the fold at cursor (plugin function documented in README).
  require("narrowing").narrow_fold()

  -- Now we're inside the narrowed buffer: set buffer-local folds.
  if t == "doc" then
    fold_cols_in_narrow()
  elseif t == "col" then
    fold_docs_in_narrow()
  end
end

-- -----------------------------
-- Keymaps
-- -----------------------------
-- Call this once from your init.lua after requiring this module.

function M.setup_keymaps()
  local map = vim.keymap.set
  local opts = { silent = true, noremap = true }

  -- Structural jumps
  map("n", "]d", next_doc, opts) -- next document header
  map("n", "[d", prev_doc, opts) -- previous document header
  map("n", "]c", next_col, opts) -- next collection header
  map("n", "[c", prev_col, opts) -- previous collection header

  -- View/render without narrowing
  map("n", "<leader>nv", M.view_here, opts) -- "navigate view": detect doc/COL at cursor and apply folds
  map("n", "<leader>ni", M.go_inner, opts)  -- go inner (down one structural step)
  map("n", "<leader>no", M.go_outer, opts)  -- go outer (up one structural step)

  -- Focus (narrow) only when you want it
  map("n", "<leader>nn", M.focus_smart, opts) -- narrow current doc/COL + apply folding in narrowed buffer
end

return M

