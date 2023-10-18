return {
    "tpope/vim-sleuth",   -- Indent autodetection with editorconfig support
    "tpope/vim-surround", -- Change surrounding braces easily

    -- Search
    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = { "kyazdani42/nvim-web-devicons" },
        cmd = "FzfLua",
        opts = {
            fzf_opts = {
                ["--layout"] = "default"
            }
        },
        keys = {
            {
                "<S-f>",
                "<cmd>FzfLua live_grep<CR>",
                desc = "Find in project"
            },
            {
                "<leader>h",
                "<cmd>FzfLua oldfiles<CR>",
                desc = "Show history"
            },
            {
                "<S-l>",
                "<cmd>FzfLua builtin<CR>",
                desc = "Builtin lists"
            }
        }
    },
    -- color highlighting
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require "colorizer".setup()
        end
    },
    -- Comments
    {
        "numToStr/Comment.nvim",
        opts = {}
    }
}
