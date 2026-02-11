vim.opt.wrap = false
vim.opt.textwidth = 0
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.syntax = on
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.cmd [[ 
	autocmd BufRead,BufNewFile *.sh set filetype=sh
	autocmd BufWritePre *.sh %s/\s\+$//e
	autocmd BufWritePost *.sh if getline(1) =~ '^#!' | silent !chmod +x % | endif
	autocmd Syntax * syn match ExtraWhitespace /\s\+$/
	autocmd FileType sh syntax match TodoComment /#.*\(TODO\|FIXME\).*/ containedin=.*Comment
	highlight TodoComment ctermfg=yellow guifg=yellow
	highlight ExtraWhitespace ctermbg=red guibg=red

]]

vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")

-- make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>")	-- make current file executable
vim.keymap.set("n", "<leader>R", ":w<CR>:!bash %<CR>")	-- make current file executable
-- Run shellcheck on the current script
vim.keymap.set("n", "<leader>sc", function()
  local filename = vim.fn.expand("%")
  vim.cmd("write")  -- Save file first
  vim.cmd("!" .. "shellcheck " .. filename)
end, {
  desc = "Run shellcheck",
  noremap = true,
  silent = true
})

-- Automatically create if, case, for-loop, function, and variable templates
vim.keymap.set("n", "<leader>v", "I@=\"$(@)\"<ESC>k0/@<CR>cl")
vim.keymap.set("n", "<leader>i", "Iif [ @ ]; then <CR>@<CR>else<CR>@<CR>fi<ESC>5k0/@<CR>cl")
vim.keymap.set("n", "<leader>ca", "Icase \"$@\" in<CR><CR>@)<CR>@<CR>;;<CR><CR>esac<ESC>6k0/@<CR>cl")
vim.keymap.set("n", "<leader>fn", "I@() {<CR>    @<CR>}<ESC>4k0/@<CR>cl")
vim.keymap.set("n", "<leader>fl", "Ifor i in @<CR>do<CR>@<CR>done<ESC>3k0/@<CR>cl")
vim.keymap.set("n", "<leader>wl", "Iwhile [ @ ]<CR>do<CR>@<CR>done<ESC>3k0/@<CR>cl")

-- comment/uncomment current line
vim.keymap.set("n", "<leader>cl", "I#<ESC>" )
vim.keymap.set("n", "<leader>uc", "I<ESC>x" )

-- color error message
vim.keymap.set("n", "<leader>eeo", "Iprintf \"%b@errormessage%b\\n\" \"$red\" \"$nc\"  && exit @ <ESC>0/@<CR>ct%" )
vim.keymap.set("n", "<leader>eo", "Iprintf \"%b%s%b\\n\" \"$red\" \"@\" \"$nc\"  && exit @ <ESC>0/@<CR>cl" )
-- color warning message
vim.keymap.set("n", "<leader>wwo", "Iprintf \"%b@statusmessage%b\\n\" \"$yellow\" \"$nc\"<ESC>0/@<CR>ct%" )
vim.keymap.set("n", "<leader>wo", "Iprintf \"%b%s%b\\n\" \"$yellow\" \"@\" \"$nc\"<ESC>0/@<CR>cl" )
-- color status message
vim.keymap.set("n", "<leader>sso", "Iprintf \"%b@statusmessage%b\\n\" \"$green\" \"$nc\"<ESC>0/@<CR>ct%" )
vim.keymap.set("n", "<leader>so", "Iprintf \"%b%s%b\\n\" \"$green\" \"@\" \"$nc\"<ESC>0/@<CR>cl" )

-- Automatically create if, case, and function templates in insert mode
--vim.keymap.set("i", ",i", "if [ @ ]; then<CR>@<CR><ESC>Ielse<CR>@<CR>fi<ESC>5k0/@<CR>cl")
--vim.keymap.set("i", ",ca", "case \"$@\" in <CR><CR> @)<CR>@<CR>;;<CR><CR>esac<ESC>6k0/@<CR>cl")
--vim.keymap.set("i", ",fn", "@() {<CR>    @<CR>}<ESC>3k0/@<CR>cl")
--vim.keymap.set("i", ",fl", "for i in @<CR>do<CR>@<CR>done<ESC>3k0/@<CR>cl")
--vim.keymap.set("i", ",wl", "while [ @ ]<CR>do<CR>@<CR>done<ESC>3k0/@<CR>cl")


