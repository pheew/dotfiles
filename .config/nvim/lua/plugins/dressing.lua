-- Provides some nicer UI for selection windows and such
return {
    "stevearc/dressing.nvim",
    opts = {
        select = {
            telescope = require("telescope.themes").get_cursor()
        }
    }
}
