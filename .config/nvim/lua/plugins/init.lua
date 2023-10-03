return {
    -- Filetype
    "nathom/filetype.nvim",
    -- session manager
    -- {
    --     "jedrzejboczar/possession.nvim",
    --     dependencies = {"nvim-lua/plenary.nvim"},
    --     lazy = false,
    --     opts = {
    --         debug = true,
    --         autosave = {
    --             current = true, -- or fun(name): boolean
    --             tmp = true, -- or fun(): boolean
    --             tmp_name = "tmp", -- or fun(): string
    --             on_load = true,
    --             on_quit = true
    --         }
    --     }
    -- },
    -- {
    --     "rmagatti/auto-session",
    --     config = function()
    --         require("auto-session").setup {
    --             log_level = "error"
    --             -- auto_session_suppress_dirs = {"~/", "~/Projects", "~/Downloads", "/"}
    --         }
    --     end
    -- }
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {options = {"buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp"}},
        -- stylua: ignore
        keys = {
            {"<leader>qs", function()
                    require("persistence").load()
                end, desc = "Restore Session"},
            {"<leader>ql", function()
                    require("persistence").load({last = true})
                end, desc = "Restore Last Session"},
            {"<leader>qd", function()
                    require("persistence").stop()
                end, desc = "Don't Save Current Session"}
        }
    }
}
