Plug 'neoclide/jsonc.vim'

" temp fix, once it's fixed upstream this can removed
autocmd BufNewFile,BufRead tsconfig*.json setlocal filetype=jsonc
