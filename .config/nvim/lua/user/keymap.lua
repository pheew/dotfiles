local m = require 'lib.utils'.keymap

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Easy config file changes
m('', '<leader>vc', ':e $MYVIMRC<cr>', { silent = true})
m('', '<leader>vr', ':luafile $MYVIMRC<cr> :echo "config reloaded"<cr>')

-- Find buffer
m('n', ';', [[<cmd>lua require('telescope.builtin').buffers()<CR>]])

-- Find file in project
m('n', '<C-p>', [[<cmd>lua require('telescope.builtin').find_files()<CR>]])

-- Find in project
m('n', '<S-f>', [[<cmd>lua require('telescope').extensions.live_grep_raw.live_grep_raw()<CR>]])
-- nmap <silent> <S-f> :Telescope live_grep<cr>

-- Open file explorer
m('', '<C-n>', ':Fern . -reveal=% -wait<CR>', { silent = true})

-- Show history
m('n', '<leader>h', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]])
