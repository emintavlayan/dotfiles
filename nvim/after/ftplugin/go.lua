vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.commentstring = "// %s"

vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")

vim.keymap.set("n", "<leader>v", "Ivar @ =\"@\"<ESC>k0/@<CR>cl")
vim.keymap.set("n", "<leader>fl", "Ifor @ :=@; @ < @; @++{<CR>fmt.Println(@)<CR>}<ESC>3k0/@<CR>cl")
vim.keymap.set("n", "<leader>cs", "Iconst @ = \"@\"<ESC>k0/@<CR>cl")
vim.keymap.set("n", "<leader>pl", "Ifmt.Println(@)<ESC>k0/@<CR>cl")

vim.cmd([[
  match ErrorMsg '\s\+$'
]])

vim.opt.textwidth = 100

vim.opt.keywordprg = "go doc"

vim.opt_local.iskeyword:append("_")

vim.opt.makeprg = "go build"
vim.opt.errorformat = "%f:%l:%c: %m"

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.cmd("silent! %!gofmt")
  end,
  --buffer = 0,
})

-- run current go file
vim.api.nvim_buf_create_user_command(0, "RunGo", function()
  vim.cmd("w") -- save first
  vim.cmd("!go run %")
end, { desc = "Run current Go file" })

-- run tests in current package
vim.api.nvim_buf_create_user_command(0, "GoTest", function()
  vim.cmd("w") -- save file
  vim.cmd("!go test")
end, { desc = "Run go test in current package" })

-- run tests in current file
vim.api.nvim_buf_create_user_command(0, "GoTestFile", function()
  local filename = vim.fn.expand("%:t")
  vim.cmd("w") -- save file
  vim.cmd("!go test -v -run ^ " .. filename)
end, { desc = "Run go test in current file" })

-- manual linting with golint if it's installed
vim.api.nvim_buf_create_user_command(0, "GoLint", function()
  vim.cmd("w")
  vim.cmd("!golint %")
end, { desc = "Run golint on current file" })

