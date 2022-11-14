vim.cmd [[

    let g:fern#renderer = "nerdfont"
    let g:fern#default_hidden = 1

    function! s:init_fern() abort
      nmap <buffer> <C-n> <Plug>(fern-action-new-path)
    endfunction

    augroup fern-custom
      autocmd! *
      autocmd FileType fern call s:init_fern()
    augroup END
]]
