vim.o.termguicolors = true

-- syntax enable

vim.o.background = "light"

-- " colorscheme solarized8
-- autocmd vimenter * ++nested colorscheme solarized8

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4

vim.o.scrolloff = 8 -- keeps some cursor context when scrolling

-- " TextEdit might fail if hidden is not set.
-- set hidden

vim.o.backup = true
vim.o.backupdir = vim.fn.stdpath("data") .. "/backup//"

-- " Give more space for displaying messages.
-- set cmdheight=2

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.o.updatetime = 300

vim.o.timeout = true
vim.o.timeoutlen = 300

vim.g.mapleader = " "

--vim.do_filetype_lua = 1
--vim.g.did_load_filetypes = 0
--

vim.diagnostic.config({ virtual_text = true })
