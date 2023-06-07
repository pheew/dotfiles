vim.g.mapleader = " "

return {
    --"wbthomason/packer.nvim", -- Let packer manage itself
    "tpope/vim-sleuth", -- Indent autodetection with editorconfig support
    "tpope/vim-surround", -- Change surrounding braces easily
    -- File explorer
    {
        "lambdalisue/fern.vim",
        branch = "main",
        dependencies = {
            "lambdalisue/nerdfont.vim",
            "lambdalisue/fern-renderer-nerdfont.vim",
            "lambdalisue/fern-hijack.vim"
        },
        init = function()
            require("user.plugins.fern")
        end
    },
    -- Theme
    {
        "lifepillar/vim-solarized8",
        init = function()
            vim.g.solarized_diffmode = "high"
            vim.cmd [[
                    autocmd vimenter * ++nested colorscheme solarized8
                    colorscheme solarized8 
            ]]
        end
    },
    -- Adds git integration
    {
        "tpope/vim-fugitive",
        dependencies = "tpope/vim-rhubarb"
        --cmd = 'G',
    },
    -- Filetype
    "nathom/filetype.nvim",
    -- Use treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/playground",
            "nvim-treesitter/nvim-treesitter-textobjects",
            "lewis6991/spellsitter.nvim",
            "JoosepAlviste/nvim-ts-context-commentstring"
        },
        config = function()
            require("user.plugins.treesitter")
            require("spellsitter").setup()
        end
    },
    -- Adds Language Server Protocol config
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "b0o/schemastore.nvim"
            --'folke/lsp-colors.nvim',
        },
        config = function()
            require("user.plugins.lspconfig")
        end
    },
    {
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require("user.plugins.trouble")
        end
    },
    -- Add completion. Plugins are adding:
    -- symbols from lsp
    -- snippets
    -- words from buffer
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
            "jessarcher/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "onsails/lspkind-nvim",
            "hrsh7th/cmp-nvim-lsp-signature-help"
        },
        config = function()
            require("user.plugins.cmp")
        end
    },
    -- Nice code outline for current buffer
    {
        "simrat39/symbols-outline.nvim",
        dependencies = {"neovim/nvim-lspconfig"}
    },
    -- Adds status line and tab line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {"kyazdani42/nvim-web-devicons", opt = true},
        config = function()
            require("user.plugins.lualine")
        end
    },
    -- Adds searchable cheatsheet
    {
        "sudormrfbin/cheatsheet.nvim",
        dependencies = {
            {"nvim-telescope/telescope.nvim"}
        }
    },
    -- Adds code formatting support
    {
        "sbdchd/neoformat",
        config = function()
            require("user.plugins.neoformat")
        end
    },
    -- Adds interactive help
    {
        "folke/which-key.nvim",
        config = function()
            require("user.plugins.which-key")
        end
    },
    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = {"kyazdani42/nvim-web-devicons"},
        config = function()
            require("user.plugins.fzf-lua")
        end
    },
    -- greeter
    {
        "goolord/alpha-nvim",
        dependencies = {"kyazdani42/nvim-web-devicons"},
        config = function()
            require "alpha".setup(require "alpha.themes.startify".config)
        end
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
        config = function()
            require("Comment").setup()
        end
    },
    -- session manager
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup {
                log_level = "error"
                -- auto_session_suppress_dirs = {"~/", "~/Projects", "~/Downloads", "/"}
            }
        end
    },
    {
        "rmagatti/session-lens",
        dependencies = {"rmagatti/auto-session", "nvim-telescope/telescope.nvim"},
        config = function()
            require("session-lens").setup(
                {
                    prompt_title = "Let's have a sesh",
                    previewer = true
                }
            )
        end
    }
}
