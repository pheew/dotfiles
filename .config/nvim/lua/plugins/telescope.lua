return {
    -- Provides searchable lists
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
            -- Add support for LuaSnip in telescope
            "benfowler/telescope-luasnip.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
            },
            "nvim-telescope/telescope-live-grep-raw.nvim"
        },
        keys = {
            {
                ";",
                "<cmd>Telescope buffers<CR>",
                desc = "Buffer list"
            },
            {
                "<leader>s",
                "<cmd>Telescope luasnip<CR>",
                desc = "Show available snippets"
            }
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<esc>"] = "close"
                    }
                }
            },
            pickers = {
                buffers = {
                    -- sort_lastused = true,
                    sort_mru = true,
                    ignore_current_buffer = true,
                    mappings = {
                        i = {
                            ["<C-d>"] = "delete_buffer"
                        }
                    }
                }
            }
        }
    }
}
