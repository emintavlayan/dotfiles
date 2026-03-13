-- STATUSLINE --

local palette = require('custom.colors.retrobox').palette

-- statusline colors
vim.cmd ('highlight StatusNorm guibg=' .. palette.white .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusLineNum guibg=' .. palette.bright_yellow .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusType guibg=' .. palette.bright_cyan .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusFile guibg=' .. palette.cyan .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModified guibg=' .. palette.black .. ' guifg=' ..palette.bright_red)
vim.cmd ('highlight StatusReadOnly guibg=' .. palette.black .. ' guifg=' ..palette.red)
vim.cmd ('highlight StatusHelp guibg=' .. palette.black .. ' guifg=' ..palette.purple)
vim.cmd ('highlight StatusBuffer guibg=' .. palette.black .. ' guifg=' ..palette.bright_cyan)
vim.cmd ('highlight StatusLocation guibg=' .. palette.blue .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusPercent guibg=' .. palette.white .. ' guifg=' ..palette.black)

-- statusline mode colors
vim.cmd ('highlight StatusModeNorm guibg=' .. palette.yellow .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModeInsert guibg=' .. palette.green .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModeVisual guibg=' .. palette.cyan .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModeReplace guibg=' .. palette.bright_red .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModeCommand guibg=' .. palette.purple .. ' guifg=' ..palette.black)
vim.cmd ('highlight StatusModeTerm guibg=' .. palette.bright_white .. ' guifg=' ..palette.black)

local modes = {
  ["n"]  = "NORMAL",
  ["no"] = "NORMAL",
  ["v"]  = "VISUAL",
  ["V"]  = "VISUAL LINE",
  [""]  = "VISUAL BLOCK",
  ["s"]  = "SELECT",
  ["S"]  = "SELECT LINE",
  [""]  = "SELECT BLOCK",
  ["i"]  = "INSERT",
  ["ic"] = "INSERT",
  ["R"]  = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"]  = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"]  = "PROMPT",
  ["rm"] = "MORE",
  ["r?"] = "CONFIRM",
  ["!"]  = "SHELL",
  ["t"]  = "TERMINAL",
}

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  return string.format(" %s ", modes[current_mode]):upper()
end

local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = "%#StatusNorm#"

  if current_mode == "n" then
    mode_color = "%#StatusModeNorm#"
  elseif current_mode == "i" or current_mode == "ic" then
    mode_color = "%#StatusModeInsert#"
  elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
    mode_color = "%#StatusModeVisual#"
  elseif current_mode == "R" then
    mode_color = "%#StatusModeReplace#"
  elseif current_mode == "c" then
    mode_color = "%#StatusModeCommand#"
  elseif current_mode == "t" then
    mode_color = "%#StatusModeTerm#"
  end

  return mode_color
end

Statusline = {}

-- ACTIVE STATUSLINE (ASCII SAFE)
Statusline.active = function()
  return table.concat {
    "%#StatusLineNum#",
    "> %l ",                         -- arrow replaced with ASCII
    "%#StatusNorm# | ",
    update_mode_colors(),
    mode(),
    "%#StatusNorm# | ",
    "%#StatusType# %Y : ",           -- separator instead of glyph
    "%#StatusNorm# ",
    "%#StatusFile# FILE %F ",         -- FILE instead of icon
    "%#StatusNorm# ",
    "%=",
    "%#StatusReadOnly# RO:%R ",
    "%#StatusModified# MOD:%m ",
    "%#StatusNorm# ",
    "%#StatusHelp# HELP:%h ",
    "%#StatusBuffer# BUF %n ",        -- BUF instead of icon
    "%#StatusNorm# | ",
    "%#StatusLocation# @ %l,%c ",     -- @ instead of glyph
    "%#StatusNorm# | ",
    "%#StatusPercent# %p%% END ",     -- END instead of arrow
    "%#StatusNorm# ",
  }
end

-- INACTIVE STATUSLINE
function Statusline.inactive()
  return "%#StatusNorm# FILE %F"
end

-- SHORT STATUSLINE (Tree / special buffers)
function Statusline.short()
  return "%#StatusNorm# [TREE] File Explorer"
end

-- AUTOCOMMANDS
vim.api.nvim_exec([[
  augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
    au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
    au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
  augroup END
]], false)
