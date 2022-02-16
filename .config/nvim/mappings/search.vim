" Find buffer
nnoremap ; :Buffer<CR>

" Find file in project
nnoremap <C-p> :Files<CR>

" Find in project
nmap <silent> <S-f> :RG<cr>

" Open file explorer
map <C-n> :Fern . -reveal=% -wait<CR>
