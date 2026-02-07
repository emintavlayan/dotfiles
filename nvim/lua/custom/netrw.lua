-- netrw config

vim.g.netrw_quit_open = 1 -- test

vim.g.netrw_banner = 1	    	-- gets rid of the annoying banner for netrw
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 0				 	-- change from left splitting to right splitting
vim.g.netrw_liststyle = 3			-- tree style view in netrw
vim.g.netrw_winsize = 50      -- takes up 30% of the screen
vim.g.netrw_sizestyle = "H"
vim.g.netrw_sort_sequence = [[[\/]$,*]] -- sort directories first
vim.g.netrw_keepdir = 0
vim.g.netrw_sizestyle = "H"
vim.g.netrw_localcopydircmd = "cp -r"
vim.g.netrw_localmkdir = "mkdir -p"
vim.g.netrw_localrmdir = "rm -r"
vim.g.netrw_compress = "gzip"
vim.g.netrw_cursor = 2
vim.g.netrw_preview = 0
vim.g.netrw_alto = 1

-- directory names are blue
vim.api.nvim_set_hl(0, "netrwDir", { fg = "#83a598" })
-- classify symbols "/" are green
vim.api.nvim_set_hl(0, "netrwClassify", { fg = "#b8bb26" })
-- executable files are yellow
vim.api.nvim_set_hl(0, "netrwExe", { fg = "#fabd2f" })
-- symlinks are purple 
vim.api.nvim_set_hl(0, "netrwExe", { fg = "#d3869b" })
-- marked files are orange
vim.api.nvim_set_hl(0, "netrwExe", { fg = "#fe8019" })
