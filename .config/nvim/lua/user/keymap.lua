vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Allow gf to open non-existent files
vim.keymap.set("", "gf", ":edit <cfile><CR>", { desc = "Open file under cursor" })

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Easy config file changes
vim.keymap.set("", "<leader>vc", ":e $MYVIMRC<cr>", { silent = true, desc = "Edit vimrc" })
vim.keymap.set("", "<leader>vr", ':luafile $MYVIMRC<cr> :echo "config reloaded"<cr>', { desc = "Reload vimrc" })

vim.keymap.set("n", "<leader>b", "<cmd>bd<cr>", { silent = true, desc = "Delete [b]uffer" })

vim.keymap.set("n", "<leader>p", "<cmd>Lazy<cr>", { silent = true, desc = "Open Lazy package manager" })
