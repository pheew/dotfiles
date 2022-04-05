local telescope = require "telescope"
local actions = require "telescope.actions"

telescope.setup {
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close
            }
        }
    },
    pickers = {
        buffers = {
            sort_lastused = true
        }
    }
}

require("telescope").load_extension "fzf"
