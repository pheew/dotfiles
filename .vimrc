if has('vim_starting')

	set nocompatible              " be iMproved, required

	" Required
	set runtimepath+=~/.vim/bundle/neobundle.vim/

endif

call neobundle#begin(expand('~/vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'fatih/vim-go'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Valloric/YouCompleteMe', {'build': { 'unix': './install.sh', 'mac': './install.sh',	}}
NeoBundle 'bling/vim-airline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'sandeepcr529/Buffet.vim'
NeoBundle 'elzr/vim-json'
NeoBundle 'mxw/vim-jsx'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'bronson/vim-trailing-whitespace'

call neobundle#end()





if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif
syntax enable
set background=dark

"let g:solarized_termcolors=256
let g:solarized_contrast='high'
colorscheme solarized

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Don't open new buffer if file is already open
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                     \ exe "normal g'\"" | endif

let mapleader=","

" Show line numbers
set number

" Ctrl-P
nnoremap <Leader>p :CtrlP<cr>
set wildignore+=*/node_modules/*

" vim-go

au FileType go nmap <Leader>i <Plug>(go-info)

au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)

au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)

" airline
let g:airline_powerline_fonts=1
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline_mode_map = {
\ '__' : '-',
\ 'n' : 'N',
\ 'i' : 'I',
\ 'R' : 'R',
\ 'c' : 'C',
\ 'v' : 'V',
\ 'V' : 'V',
\ 's' : 'S',
\ 'S' : 'S',
\ }

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" Buffer buffer switching

noremap <silent> <C-Tab> :Bufferlistsw<CR>
noremap <silent> <C-S-Tab> :Bufferlistsw<CR>kk
if !has('gui')
	map <S-q> :Bufferlistsw<CR>
endif

augroup BuffetAdd
	if !exists("g:BuffetAdded")
		let g:BuffetAdded = 1
		au BufWinEnter buflisttempbuffer* map <buffer> <Tab> <CR>
		au BufWinEnter buflisttempbuffer* map <buffer> <C-Tab>   j
		au BufWinEnter buflisttempbuffer* map <buffer> <C-S-Tab> k
		" in console Vim we can't use <C-Tab> mappings (almost always),
		" so this is temporary solution: <S-q>

		if !has('gui')
			au BufWinEnter buflisttempbuffer* map <buffer> <S-q> j
			au BufWinEnter buflisttempbuffer* map <buffer> q <CR>
		endif
		" workaround Surround plugin issue in Buffet's window:
		" disable \"ds\" mapping in the Buffet window (to make "d" work fast)
		au BufEnter buflisttempbuffer* nunmap ds
		au BufLeave buflisttempbuffer* nmap   ds <Plug>Dsurround

   endif
augroup END

set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab


NeoBundleCheck
