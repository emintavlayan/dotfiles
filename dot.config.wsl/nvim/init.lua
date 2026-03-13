-- Essential for iSH: cache lua bytecode
if vim.loader then vim.loader.enable() end

-- BOOTSTRAP LAZY.NVIM 
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. BASIC SETTINGS (Performance-focused)
vim.g.mapleader = " "

vim.opt.spell = false
vim.o.backup = false				-- turn off backup file
vim.o.writebackup = false			-- do not write backup
vim.o.swapfile = false				-- turn off swapfile
vim.o.undofile = true				-- set undo file
vim.o.undodir = vim.fn.expand("~/.local/share/nvim/undodir")
vim.o.updatetime = 300				-- decrease update time to improve snappiness
vim.o.cursorline = true				-- set highlighted cursor line
vim.o.autoread = true		  		-- re-read files in case they were edited outside of vim
vim.o.autowrite = false				-- do not auto write file when changing buffers and such
vim.o.number = true			  		-- turn on line numbers
vim.o.relativenumber = true		    -- turn on relative line numbers
vim.o.mouse = 'a'				  	-- enable the mouse in all modes
vim.o.ignorecase = true				-- enable case insensitive searching
vim.o.smartcase = true				-- all searches are case insensitive unless there's a capital letter
vim.o.smartindent = true			-- smart auto-indenting when starting a new line
vim.o.hlsearch = false				-- disable all highlighted search results
vim.o.incsearch = true				-- enable incremental searching
vim.o.wrap = false				  	-- enable text wrapping
vim.o.tabstop = 4				  	-- tabs=4spaces
vim.o.shiftwidth = 4				-- tabs=4spaces
vim.o.expandtab = true			    -- convert tabs to spaces
vim.o.pumheight = 10				-- number of items in popup menu
vim.o.showtabline = 1				-- always show the tab line
vim.o.laststatus = 2				-- always show statusline
vim.o.signcolumn = "auto"			--  only use sign column when there is something to put there
vim.o.colorcolumn = "80"			-- set color column to 80 characters
vim.o.showcmd = true			    -- show the command
vim.o.showmatch = true				-- highlight matching brackets
vim.o.cmdheight = 1				  	-- set command line height
vim.o.showmode = false				-- do not show the mode since it's already in the status line
vim.o.scrolloff = 8				  	-- scroll page when cursor is 8 lines from top/bottom
vim.o.sidescrolloff = 8				-- scroll page when cursor is 8 spaces from left/right
vim.o.clipboard = "unnamedplus"     -- use the system clipboard
vim.o.wildmenu = true               -- use the wild menu
vim.o.wildmode = "longest:full,full"-- set wile menu options
vim.o.path = "+=**"                 -- search files recursively
vim.o.splitbelow = true				-- split go below
vim.o.splitright = true				-- vertical split to the right
vim.o.termguicolors = true  		-- terminal gui colors
vim.o.cmdwinheight = 10             -- cmd window can only take up this many lines

-- automatically highlight yanked text
local HlGrp = vim.api.nvim_create_augroup('highlighter', {clear = true})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = HlGrp,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- automatically ceate directories when saving files
local AutoDirGroup = vim.api.nvim_create_augroup("AutoCreateDir", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = AutoDirGroup,
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- 3 Lazy SETUP
require("lazy").setup({

  -- THEME NightFox but CarbonFox
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = false,
          styles = { comments = "italic" },
        }
      })
      vim.cmd.colorscheme "carbonfox" -- or nightfox, duskfox, nordfox
      
      -- Darken the bars for contrast
      local colors = require("nightfox.palette").load("carbonfox")
      vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bg = colors.sel0.base, fg = colors.blue.base })
      vim.api.nvim_set_hl(0, "MiniTablineActive", { bg = colors.sel0.base, fg = colors.white.base, bold = true })
    end,
  },

  -- UI: Mini.nvim (Statusline & Tabline without icons)
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Statusline (Bottom bar)
      require('mini.statusline').setup({ use_icons = false })
      -- Tabline (Top bar for buffers)
      require('mini.tabline').setup({ show_icons = false })
      -- Autopairs (brackets/quotes)
      require('mini.pairs').setup({})
    end
  },

  -- FILE EXPLORER: Oil.nvim (Low memory alternative to tree)
  {
    "stevearc/oil.nvim",
    opts = {
      columns = {}, -- No icons for iSH
      view_options = { show_hidden = true },
    },
  },
})

-- 4. KEYMAPS
local map = vim.keymap.set

-- oil file explorer
map("n", "<leader>e", ":Oil<CR>", { desc = "File Explorer" })

-- buffer management
map("n", "<Tab>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", ":bprev<CR>", { desc = "Prev Buffer" })
map("n", "<leader>x", ":bd<CR>", { desc = "Close Buffer" })

-- toggle line wrapping
map("n", "<leader>w", ":set wrap!<CR>") 

-- toggle search highlights
map("n", "<leader>hl", ":set hlsearch!<CR>")		

-- centered navigation
map("n", "n", "nzzzv", {desc = "Next search result (centered on screen)"})
map("n", "N", "Nzzzv", {desc = "Previous search result (centered on screen)"})
map("n", "<C-d>", "<C-d>zz", {desc = "Half page down (centered)"})
map("n", "<C-u>", "<C-u>zz", {desc = "Half page up (centered)"})

-- easy split generation
map("n", "<leader>vs", ":vsplit ")  -- space+v creates a veritcal split
map("n", "<leader>hs", ":split ")   -- space+s creates a horizontal split

-- easy split navigation
map("n", "<C-h>", "<C-w>h")		    -- control+h switches to left split
map("n", "<C-l>", "<C-w>l")		    -- control+l switches to right split
map("n", "<C-j>", "<C-w>j")		    -- control+j switches to bottom split
map("n", "<C-k>", "<C-w>k")		    -- control+k switches to top split

-- Easy way to get back to normal mode from home row
map("i", "jj", "<Esc>")				-- jj simulates ESC
map("i", "jk", "<Esc>")				-- jk simulates ESC

-- insert mode navigation
map("i", "<C-h>", "<left>")			-- control+h moves cursor left
map("i", "<C-l>", "<right>")		-- control+l moves cursor right
map("i", "<C-j>", "<down>")			-- control+j moves cursor down
map("i", "<C-k>", "<up>")			-- control+k moves cursor up

-- Replace all instances of highlighted words
map("v", "<leader>r", "\"hy:%s/<C-r>h//g<left><left>")			

-- Sort highlighted text in visual mode with Control+S
map("v", "<C-s>", ":sort<CR>")									

-- Move selected blocks around
map("x", "J", ":m '>+1<CR>gv=gv")
map("x", "K", ":m '<-2<CR>gv=gv")	

