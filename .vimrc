set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vim/bundle/managed')

Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'kien/ctrlp.vim'

call vundle#end()            " required
filetype plugin indent on    " required



set guifont=Consolas:h12:cANSI
colorscheme vibrantink
syntax on

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Don't open new buffer if file is already open
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                     \ exe "normal g'\"" | endif 

