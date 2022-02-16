Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" fzf setup
set wildignore+=**/node_modules/*
set wildignore+=**/dist/*

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }

nnoremap <leader>h :Commits<CR>

if executable('rg')
	let $FZF_DEFAULT_COMMAND = 'rg --glob="!.git/*" --hidden -l ""'
endif


