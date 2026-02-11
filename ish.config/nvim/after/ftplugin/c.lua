vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = false
vim.opt.textwidth = 0
vim.opt.expandtab = false

-- automatically close quotes, parenthesis, and brackets
vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "{;", "{};<left><left>")
vim.keymap.set("i", "/*", "/**/<left><left>")

--comment out lines in C
vim.keymap.set("n", "<leader>cl", "I/*<ESC>A*/<ESC>")
vim.keymap.set("n", "<leader>uc", "0d2lA<left><ESC>d$<ESC>")

-- automatically type out include lines
vim.keymap.set("n", "<leader>in", "I#include <><left>")

