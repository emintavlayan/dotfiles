vim.opt.shiftwidth = 2       -- indent size
vim.opt.tabstop = 2          -- number of spaces per tab
vim.opt.expandtab = true     -- use spaces instead of tabs
vim.opt.autoindent = true    -- copy indent from current line when starting an new one
vim.opt.smartindent = true   -- smart autoindenting for new lines
vim.opt.wrap = true
vim.opt.textwidth = 80

vim.cmd("syntax enable")

vim.opt.commentstring = "-- %s"

vim.opt_local.iskeyword:append("_")

vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")

vim.keymap.set("n", "<leader>cl", "I--<ESC>")
vim.keymap.set("n", "<leader>uc", "0d2l")

-- function template
vim.keymap.set("n", "<leader>fn", "Ifunction @(@)<CR>@<CR>end<ESC>2k0/@<CR>cl")
