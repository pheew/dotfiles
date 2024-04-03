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
            'fzf-tmux',
            fzf_opts = {
                ["--layout"] = "default"
            }
        },
        keys = {
            {
                "<C-p>",
                "<cmd>FzfLua git_files<CR>",
                desc = "Find file in project"
            },
            {
                ";",
                "<cmd>FzfLua buffers<CR>",
                desc = "Buffer list"
            },
            {
                "<S-f>",
                "<cmd>FzfLua live_grep_glob<CR>",
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

    -- search/replace in multiple files
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        opts = { open_cmd = "noswapfile vnew" },
        -- stylua: ignore
        keys = {
            { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
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
    },

    -- Jumping around
    {
        "ggandor/leap.nvim",
        enabled = true,
        keys = {
            { "s",  mode = { "n", "x", "o" }, desc = "Leap forward to" },
            { "S",  mode = { "n", "x", "o" }, desc = "Leap backward to" },
            { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
        },
        config = function(_, opts)
            local leap = require("leap")
            for k, v in pairs(opts) do
                leap.opts[k] = v
            end
            leap.add_default_mappings(true)
            vim.keymap.del({ "x", "o" }, "x")
            vim.keymap.del({ "x", "o" }, "X")
        end,
    }
}
