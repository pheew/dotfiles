local telescope = require 'telescope'
local actions = require 'telescope.actions'
local keymap = require 'lib.utils'.keymap

telescope.setup {
	defaults = {
		mappings = {
			i = {
				['<esc>'] = actions.close,
			}
		}
	},
	pickers = {
	  buffers = {
	    sort_lastused = true
	  }
	}
}


require('telescope').load_extension 'fzf'
