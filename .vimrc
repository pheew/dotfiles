if has('vim_starting')
	set nocompatible              " be iMproved, required

	" Required
	set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'fatih/vim-go'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Valloric/YourCompleteMe', {
	\ 'build': {
	\ 	'unix': './install.sh',
	\	'mac': './install.sh',
	\	}
	\}




call neobundle#end()


" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin('~/.vim/bundle/managed')

"Plugin 'gmarik/Vundle.vim'
"Plugin 'fatih/vim-go'
"Plugin 'Shougo/vimproc.vim'
"Plugin 'kien/ctrlp.vim'
"" Plugin 'Shougo/unite.vim'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'https://bitbucket.org/sras/buffet'
"call vundle#end()            " required
"filetype plugin indent on    " required


filetype plugin indent on

if has("gui_running")
  if has("gui_gtk2")
      set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif
set background=dark
colorscheme solarized
syntax on

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Don't open new buffer if file is already open
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                     \ exe "normal g'\"" | endif 

let mapleader=","

" Ctrl-P 
nnoremap <Leader>p :CtrlP<cr>

" vim-go

au FileType go nmap <Leader>i <Plug>(go-info)

au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)

au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
