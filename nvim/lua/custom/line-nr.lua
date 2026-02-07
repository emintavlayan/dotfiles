-- CURSOR LINE NUMBER --
-- define cursorline number colors for each mode
local mode_colors = {
  n = "#fabd2f",     -- normal(yellow)
  i = "#83a598",     --insert (blue)
  v = "#d3869b",     -- visual (purple)
  V = "#d3869b",     -- visual line
  [""] = "#d3869b",  -- visual block
  c = "#fe8019",     -- command-line (orange)
  R = "#fb4934",     -- replace (red)
}

-- function to update CursorLineNr color based on mode
local function update_cursorline_color()
  local mode = vim.fn.mode()
  local color = mode_colors[mode] or "#ebdbb2" -- fallback (white)
  vim.api.nvim_set_hl(0, "CursorLineNr", {fg = "#1c1c1c", bg = color, bold = true})
  --vim.api.nvim_set_hl(0, "CursorLineNr", {fg = color, bold = true})
end

-- autocommands to trigger mode change
vim.api.nvim_create_autocmd({ "ModeChanged", "VimEnter", "WinEnter", "BufEnter" }, {
  callback = update_cursorline_color,
})

