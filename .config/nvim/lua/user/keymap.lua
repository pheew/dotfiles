vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Allow gf to open non-existent files
vim.keymap.set("", "gf", ":edit <cfile><CR>")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Easy config file changes
vim.keymap.set("", "<leader>vc", ":e $MYVIMRC<cr>", {silent = true})
vim.keymap.set("", "<leader>vr", ':luafile $MYVIMRC<cr> :echo "config reloaded"<cr>')

vim.keymap.set("n", "<leader>b", "<cmd>bd<cr>", {silent = true, desc = "Delete [b]uffer"})

vim.keymap.set("n", "<leader>p", "<cmd>Lazy<cr>", {silent = true, desc = "Open Lazy package manager"})
