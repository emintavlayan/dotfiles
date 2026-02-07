-- LEADER --

vim.g.mapleader = " "					-- sets leader key
vim.g.maplocalleader = ' '

-- LAZY.NVIM -------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
-- ----------------------------------------------------------

-- OPTIONS --
vim.g.have_nerd_font = false  -- Set to true if you have a Nerd Font installed and selected in the terminal
vim.o.title = true				  	-- show title
vim.o.syntax = "ON"				  	-- set syntax to ON
vim.o.backup = false					-- turn off backup file
vim.o.writebackup = false  		-- do not write backup
vim.o.swapfile = false				-- turn off swapfile
vim.o.undofile = true					-- set undo file
vim.o.undodir = vim.fn.expand("~/.local/share/nvim/undodir")
vim.o.updatetime = 300				-- decrease update time to improve snappiness
vim.o.cursorline = true				-- set highlighted cursor line
vim.o.autoread = true		  		-- re-read files in case they were edited outside of vim
vim.o.autowrite = false				-- do not auto write file when changing buffers and such
vim.o.compatible = false			-- turn off vi compatibility mode
vim.o.number = true			  		-- turn on line numbers
vim.o.relativenumber = true		-- turn on relative line numbers
vim.o.mouse = 'a'				  		-- enable the mouse in all modes
vim.o.ignorecase = true				-- enable case insensitive searching
vim.o.smartcase = true				-- all searches are case insensitive unless there's a capital letter
vim.o.smartindent = true			-- smart auto-indenting when starting a new line
vim.o.hlsearch = false				-- disable all highlighted search results
vim.o.incsearch = true				-- enable incremental searching
vim.o.wrap = false				  	-- enable text wrapping
vim.o.tabstop = 4					  	-- tabs=4spaces
vim.o.shiftwidth = 4					-- tabs=4spaces
vim.o.expandtab = true				-- convert tabs to spaces
vim.o.pumheight = 10					-- number of items in popup menu
vim.o.showtabline = 1					-- always show the tab line
vim.o.laststatus = 2					-- always show statusline
vim.o.signcolumn = "auto"			--  only use sign column when there is something to put there
vim.o.colorcolumn = "120"			-- set color column to 120 characters
vim.o.showcmd = true					-- show the command
vim.o.showmatch = true				-- highlight matching brackets
vim.o.cmdheight = 1				  	-- set command line height
vim.o.showmode = false				-- do not show the mode since it's already in the status line
vim.o.scrolloff = 8				  	-- scroll page when cursor is 8 lines from top/bottom
vim.o.sidescrolloff = 8				-- scroll page when cursor is 8 spaces from left/right
vim.o.clipboard = "unnamedplus"  -- use the system clipboard
vim.o.wildmenu = true            -- use the wild menu
vim.o.wildmode = "longest:full,full"  -- set wile menu options
vim.o.path = "+=**"                   -- search files recursively
vim.o.splitbelow = true				-- split go below
vim.o.splitright = true				-- vertical split to the right
vim.o.termguicolors = true		-- terminal gui colors
vim.o.cmdwinheight = 10       -- cmd window can only take up this many lines
vim.opt.guifont = {"JetBrainsMono Nerd Font", ":h14"}
vim.opt.completeopt= { "menuone", "noselect" }

-- FILE TYPE --
vim.cmd("filetype plugin on")

-- NEW FILE --
vim.cmd(":autocmd BufNewFile *.md 0r ~/.config/nvim/templates/skeleton.md")
vim.cmd(":autocmd BufNewFile *.sh 0r ~/.config/nvim/templates/skeleton.sh")

-- MAKE --
--vim.cmd(":autocmd BufWritePost *.h !make")

-- THEMING --
vim.cmd.colorscheme("retrobox")
vim.api.nvim_set_hl(0, "Normal", {bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", {bg = "none" })
vim.api.nvim_set_hl(0, "ColorColumn", {bg = "#282828" })
vim.opt.guicursor = {
    "n-v-c:block",
    "i-ci-ve:block",
    "r-cr:block",
    "o:block",
    "sm:block",
}
--vim.api.nvim_set_hl(0, "EndOfBuffer", {bg = "none" })
--vim.api.nvim_set_hl(0, "NonText", {bg = "none" })
--vim.cmd([[highlight Cursor guifg=black guibg=blue]])
--vim.api.nvim_set_hl(0, "CursorLineNr", {fg = "#1c1c1c", bg="#fabd2f", bold = true })

-- REQUIRE --
require("custom.netrw")
require("custom.statusline")
require("custom.line-nr")
require("custom.popout-terminal")

-- FUNCTIONS --
-- automatically highligh yanked text
local HlGrp = vim.api.nvim_create_augroup('highlighter', {clear = true}),
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = HlGrp,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- automatically ceate directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function()
		local dir = vim.fn.expand('<afile>:p:h')
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, 'p')
		end
	end,
})

-- KEY MAPPINGS --

-- reload config
vim.keymap.set("n", "<leader>r", ":source ~/.config/nvim/init.lua<CR> \
                                  :source ~/.config/nvim/lua/custom/statusline.lua<CR> \
                                  :source ~/.config/nvim/lua/custom/line-nr.lua<CR> \
                                  :source ~/.config/nvim/lua/custom/netrw.lua<CR>")

-- toggle search highlights
vim.keymap.set("n", "<leader>hl", ":set hlsearch!<CR>")		-- toggle search highlights

-- set Caps lock to ESC
vim.keymap.set({ "i", "n", "v", "c" }, "<CapsLock>", "<Esc>", { noremap = true, silent = true })

-- centered navigation
vim.keymap.set("n", "n", "nzzzv", {desc = "Next search result (centered on screen)"})
vim.keymap.set("n", "N", "Nzzzv", {desc = "Previous search result (centered on screen)"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Half page down (centered)"})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Half page up (centered)"})

-- Open netrw in 25% split in tree view
vim.keymap.set("n", "<leader>e", ":25Lexplore<CR>")
vim.keymap.set("n", "<leader>ff", ":find ")

-- easy split generation
vim.keymap.set("n", "<leader>vs", ":vsplit ")				-- space+v creates a veritcal split
vim.keymap.set("n", "<leader>hs", ":split ")					-- space+s creates a horizontal split

-- easy split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")						-- control+h switches to left split
vim.keymap.set("n", "<C-l>", "<C-w>l")						-- control+l switches to right split
vim.keymap.set("n", "<C-j>", "<C-w>j")						-- control+j switches to bottom split
vim.keymap.set("n", "<C-k>", "<C-w>k")						-- control+k switches to top split

-- file operations
vim.keymap.set("n", "<leader>w", ":w <CR>")		  -- Space+w saves
vim.keymap.set("n", "<leader>q", ":q <CR>")			-- Space+q quits
vim.keymap.set("n", "<leader>wq", ":wq <CR>")	  -- Space+wq save and quit
vim.keymap.set("n", "<leader>qq", ":q! <CR>")		-- Space+qq quit without save

-- buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext <CR>")		  -- Tab goes to next buffer
vim.keymap.set("n", "<leader>bp", ":bprevious <CR>")	-- Shift+Tab goes to previous buffer
vim.keymap.set("n", "<leader>bd", ":bd! <CR>")				-- Space+d deletes current buffer
vim.keymap.set("n", "<leader>bl", ":ls <CR>")		  		-- Space+d lists buffers

-- adjust split sizes easier
vim.keymap.set("n", "<C-Left>", ":vertical resize -3<CR>")	-- Control+Left resizes vertical split +
vim.keymap.set("n", "<C-Right>", ":vertical resize +3<CR>")	-- Control+Right resizes vertical split -

-- Easy way to get back to normal mode from home row
vim.keymap.set("i", "jj", "<Esc>")					-- jj simulates ESC
vim.keymap.set("i", "jk", "<Esc>")					-- jk simulates ESC

-- insert mode navigation
vim.keymap.set("i", "<C-h>", "<left>")				-- control+h moves cursor left
vim.keymap.set("i", "<C-l>", "<right>")			-- control+l moves cursor right
vim.keymap.set("i", "<C-j>", "<down>")				-- control+j moves cursor down
vim.keymap.set("i", "<C-k>", "<up>")				-- control+k moves cursor up

-- Visual Maps
vim.keymap.set("v", "<leader>r", "\"hy:%s/<C-r>h//g<left><left>")			-- Replace all instances of highlighted words

vim.keymap.set('n', '<leader>rp', function()
  -- Prompt for search term
  vim.ui.input({ prompt = 'Search for: ' }, function(search_term)
    if not search_term or search_term == '' then return end

    -- Optional: add word boundaries, or remove if not needed
    local search_pattern = [[\<]] .. search_term .. [[\>]]

    -- Search project with vimgrep
    vim.cmd('vimgrep /' .. search_pattern .. '/gj **')
    vim.cmd('copen')

    -- Prompt for replacement
    vim.ui.input({ prompt = 'Replace with: ' }, function(replace_term)
      if not replace_term then return end

      -- Use cdo with confirmation (`gc`)
      vim.cmd('cdo s/' .. search_pattern .. '/' .. replace_term .. '/gc')
    end)
  end)
end, { desc = 'Project-wide search & replace (unescaped)', noremap = true })

vim.keymap.set("v", "<C-s>", ":sort<CR>")									-- Sort highlighted text in visual mode with Control+S
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")								-- Move current line down
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")								-- Move current line up

-- Move selected blocks around
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")								-- Move current line up
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")								-- Move current line down

-- DYNA THINGS ----------------------------------------------
require("dynafocus").setup_keymaps()
require("dynaoutline").setup_keymaps()
-- ----------------------------------------------------------

