-- options
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = true
vim.opt.textwidth = 78
vim.opt.wrapmargin = 80
vim.opt.colorcolumn = '80'
vim.opt.spell = true

-- fix first spelling error behind/above cursor
vim.keymap.set("n", "<leader>sp", "mm[s1z=`m")

-- folds
--vim.keymap.set("n", "<leader"ufa, funciton()
--vim.cmd("edit!"))       -- reads the file to reflect changes
--vim.cmd("normal! zR")	-- Unfold all headings
--end )

-- move current line to the position in list (paragraph).
vim.keymap.set("n", "<leader>m1", "kmmjdd{p`m")
vim.keymap.set("n", "<leader>m2", "kmmjdd{jp`m")
vim.keymap.set("n", "<leader>m3", "kmmjdd{jjp`m")
vim.keymap.set("n", "<leader>mb", "kmmjdd}p`m")

-- auto close quotes, parenthesis, and brackets
vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")

-- headers
vim.keymap.set("n", "<leader>t", "ggI# ")
vim.keymap.set("n", "<leader>h1", "ggI# ")
vim.keymap.set("n", "<leader>h2", "I## ")
vim.keymap.set("n", "<leader>h3", "I### ")

-- bold, italics, bold-italics, and strike through 
vim.keymap.set("n", "<leader>bt", "i**@**<ESC>b/@<CR>cl") 
vim.keymap.set("n", "<leader>it", "i*@*<ESC>b/@<CR>cl") 
vim.keymap.set("n", "<leader>bi", "i***@***<ESC>b/@<CR>cl")
vim.keymap.set("n", "<leader>st", "i~~@~~<ESC>b/@<CR>cl")

-- bullet list
vim.keymap.set("n", "<leader>bl", "A<CR><TAB>- @<CR>- @<ESC>3k/@<CR>cl")
vim.keymap.set("n", "<leader>nl", "A<CR><TAB>1. @<CR>2. @<ESC>3k/@<CR>cl")

-- code block
vim.keymap.set("n", "<leader>cb", "I```@<CR><CR>@<CR><CR>```<ESC>4k/@<CR>cl")

-- link
vim.keymap.set("n", "<leader>ln", "i[@]:@<ESC>b/@<CR>cl")

-- table
vim.keymap.set("n", "<leader>tbl", "I| @ | @ |<CR>|---|---|<CR>| @ | @ |<ESC>4k/@<CR>cl")

