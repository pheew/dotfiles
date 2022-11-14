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

-- Find buffer
vim.keymap.set("n", ";", ":Telescope buffers<CR>")

-- Find file in project
vim.keymap.set("n", "<C-p>", [[:FzfLua files<CR>]])

-- Find in project
vim.keymap.set("n", "<S-f>", [[:FzfLua live_grep<CR>]])

-- Open file explorer
vim.keymap.set("", "<leader>n", ":Fern . -reveal=% -wait<CR>", {silent = true})

-- Show history
vim.keymap.set("n", "<leader>h", [[<cmd>FzfLua oldfiles<CR>]])
vim.keymap.set("", "<leader>br", ":GBrowse!")

-- Builtin lists
vim.keymap.set("n", "<S-l>", [[:FzfLua builtin<CR>]])
