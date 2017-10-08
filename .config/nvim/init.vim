" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'kien/ctrlp.vim'
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'tpope/vim-surround'
Plug 'valloric/youcompleteme'

" Languages
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'ekalinin/dockerfile.vim'

" Initialize plugin system
call plug#end()

" Syntax highlight / theme 
syntax enable
set background=light
colorscheme solarized
set number

" Ignores for Ctrl-P
set wildignore+=*/node_modules/*
