nnoremap <SPACE> <Nop>
let mapleader=" "

" Basic vim settings
"
source ~/.config/nvim/settings.vim

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Coc LSP support in neovim
source ~/.config/nvim/plugins/coc.vim

" Status line plugin
source ~/.config/nvim/plugins/statusline.vim

" Theming
source ~/.config/nvim/plugins/solarized.vim

" Surround
source ~/.config/nvim/plugins/vim-surround.vim

" Fern, file explorer
source ~/.config/nvim/plugins/fern.vim

" Git support
source ~/.config/nvim/plugins/git.vim

" Fzf, for file and buffer switching
source ~/.config/nvim/plugins/fzf.vim

" Ripgrep search
source ~/.config/nvim/plugins/rg.vim

" Syntax support
source ~/.config/nvim/plugins/jsonc.vim
source ~/.config/nvim/plugins/graphql.vim
source ~/.config/nvim/plugins/yaml.vim

" Respect .editorconfig settings
source ~/.config/nvim/plugins/editorconfig.vim

" Easy comment management
source ~/.config/nvim/plugins/comment.vim

" Initialize plugin system
call plug#end()

" Mappings
"
source ~/.config/nvim/mappings/search.vim
source ~/.config/nvim/mappings/config.vim

