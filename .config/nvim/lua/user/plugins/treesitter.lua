local parser_config = require('nvim-treesitter.parsers').get_parser_configs()


require('nvim-treesitter.configs').setup {
   ensure_installed = 'maintained',
  indent = {
    enable = { 'lua', 'html', 'blade' },
  },
  highlight = {
    enable = true,
    --disable = { 'NvimTree' },
    --additional_vim_regex_highlighting = true,
  },
}

