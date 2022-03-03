require('lualine').setup {
  options = {
    theme = 'solarized_light'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {
    lualine_a = {'buffers'},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  }
}
