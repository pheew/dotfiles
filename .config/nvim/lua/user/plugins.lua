local packer = require "lib.packer-init"

packer.startup(
    function(use)
        use {"wbthomason/packer.nvim"} -- Let packer manage itself

        use {"tpope/vim-sleuth"} -- Indent autodetection with editorconfig support

        -- Change surrounding braces easily
        use {"tpope/vim-surround"}

        -- File explorer
        use {
            "lambdalisue/fern.vim",
            branch = "main",
            requires = {
                "lambdalisue/nerdfont.vim",
                "lambdalisue/fern-renderer-nerdfont.vim",
                "lambdalisue/fern-hijack.vim"
            },
            setup = function()
                require("user.plugins.fern")
            end
        }

        -- Theme
        use {
            "lifepillar/vim-solarized8",
            setup = function()
                vim.g.solarized_diffmode = "high"
                vim.cmd [[ 
				autocmd vimenter * ++nested colorscheme solarized8
				colorscheme solarized8 
			]]
            end
        }

        -- Adds git integration
        use {
            "tpope/vim-fugitive",
            requires = "tpope/vim-rhubarb"
            --cmd = 'G',
        }

        -- Provides searchable lists
        use {
            "nvim-telescope/telescope.nvim",
            requires = {
                {"nvim-lua/plenary.nvim"},
                {"kyazdani42/nvim-web-devicons"},
                {"nvim-telescope/telescope-fzf-native.nvim", run = "make"},
                {"nvim-telescope/telescope-live-grep-raw.nvim"}
            },
            config = function()
                require("user.plugins.telescope")
            end
        }

        -- Adds support for code snippets
        use {
            "L3MON4D3/LuaSnip",
            requires = {
                "honza/vim-snippets"
            },
            config = function()
                require("user.plugins.luasnip")
            end
        }

        -- Add support for LuaSnip in telescope
        use {
            "benfowler/telescope-luasnip.nvim",
            module = "telescope._extensions.luasnip" -- if you wish to lazy-load
        }

        -- Use treesitter for syntax highlighting
        use {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
            requires = {
                "nvim-treesitter/playground",
                "nvim-treesitter/nvim-treesitter-textobjects",
                "lewis6991/spellsitter.nvim",
                "JoosepAlviste/nvim-ts-context-commentstring"
            },
            config = function()
                require("user.plugins.treesitter")
                require("spellsitter").setup()
            end
        }

        -- Adds Language Server Protocol config
        use {
            "neovim/nvim-lspconfig",
            requires = {
                "hrsh7th/nvim-cmp",
                "b0o/schemastore.nvim",
                --'folke/lsp-colors.nvim',
                "weilbith/nvim-code-action-menu"
            },
            config = function()
                require("user.plugins.lspconfig")
            end
        }

        -- Add completion. Plugins are adding:
        -- symbols from lsp
        -- snippets
        -- words from buffer
        use {
            "hrsh7th/nvim-cmp",
            requires = {
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
        }

        -- Nice code outline for current buffer
        use {
            "simrat39/symbols-outline.nvim",
            requires = {"neovim/nvim-lspconfig"}
        }

        -- Adds status line and tab line
        use {
            "nvim-lualine/lualine.nvim",
            requires = {"kyazdani42/nvim-web-devicons", opt = true},
            config = function()
                require("user.plugins.lualine")
            end
        }

        -- Adds searchable cheatsheet
        use {
            "sudormrfbin/cheatsheet.nvim",
            requires = {
                {"nvim-telescope/telescope.nvim"}
            }
        }

        -- Adds code formatting support
        use {
            "sbdchd/neoformat",
            config = function()
                require("user.plugins.neoformat")
            end
        }

        -- Adds interactive help
        use {
            "folke/which-key.nvim",
            config = function()
                require("user.plugins.which-key")
            end
        }

        use {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            requires = {"kyazdani42/nvim-web-devicons"},
            config = function()
                require("user.plugins.fzf-lua")
            end
        }

        use {
            "goolord/alpha-nvim",
            requires = {"kyazdani42/nvim-web-devicons"},
            config = function()
                require "alpha".setup(require "alpha.themes.startify".config)
            end
        }

        use {
            "norcalli/nvim-colorizer.lua",
            config = function()
                require "colorizer".setup()
            end
        }

        -- Comments
        use {
            "numToStr/Comment.nvim",
            config = function()
                require("Comment").setup()
            end
        }
    end
)
