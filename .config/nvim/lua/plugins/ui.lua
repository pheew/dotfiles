return {
	-- Theme
	{
		"Tsuzat/NeoSolarized.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		opts = {
			transparent = false,
		},
		config = function(_, opts)
			require("NeoSolarized").setup(opts)

			vim.cmd([[
				autocmd vimenter * ++nested colorscheme NeoSolarized
				colorscheme NeoSolarized
			]])
		end,
	},
	-- {
	-- 	"lifepillar/vim-solarized8",
	-- 	init = function()
	-- 		vim.g.solarized_diffmode = "high"
	-- 		vim.cmd([[
	--                    autocmd vimenter * ++nested colorscheme solarized8
	--                    colorscheme solarized8
	--            ]])
	-- 	end,
	-- },

	-- File explorer
	{
		"lambdalisue/fern.vim",
		branch = "main",
		cmd = "Fern",
		dependencies = {
			"lambdalisue/nerdfont.vim",
			"lambdalisue/fern-renderer-nerdfont.vim",
			"lambdalisue/fern-hijack.vim",
			"yuki-yano/fern-preview.vim",
		},
		keys = {
			{
				-- Open file explorer
				"<leader>n",
				"<cmd>Fern . -reveal=% -wait<CR>",
				silent = true,
			},
		},
		init = function()
			vim.cmd([[
				let g:fern#renderer = "nerdfont"
				let g:fern#default_hidden = 1

				function! s:init_fern() abort
				  nmap <buffer> <C-n> <Plug>(fern-action-new-path)
				  nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
				  nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
				  nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
				  nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
				endfunction

				augroup fern-custom
				  autocmd! *
				  autocmd FileType fern call s:init_fern()
				augroup END
			    ]])
		end,
	},

	-- Improve built-in vim UI
	{
		"stevearc/dressing.nvim",
		lazy = true,
		opts = {
			select = {
				telescope = require("telescope.themes").get_cursor(),
			},
		},
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline",
			},
			messages = {
				view = "mini",
				view_error = "mini",
				view_warn = "mini",
			},
			notify = {
				view = "mini",
			},
			lsp = {
				override = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				-- command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
		},
		dependencies = {
			{
				"rcarriga/nvim-notify",
				opts = {
					render = "minimal",
				},
			},
		},
	},

	-- Adds status line and tab line
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			{ "kyazdani42/nvim-web-devicons", opt = true },
			"Tsuzat/NeoSolarized.nvim",
		},
		opts = function()
			return {
				options = {
					theme = "NeoSolarized",
					disabled_filetypes = { "fern", "alpha", "Outline" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				tabline = {
					lualine_a = {
						{
							"buffers",
							show_filename_only = false,
						},
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "tabs" },
				},
			}
		end,
	},

	-- greeter
	{
		"goolord/alpha-nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		event = "VimEnter",
		opts = function()
			return require("alpha.themes.startify").config
		end,
	},

	-- Nice symbol outline
	{
		"hedyhli/outline.nvim",
		lazy = true,
		cmd = { "Outline", "OutlineOpen" },
		keys = { -- Example mapping to toggle outline
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
		},
		opts = {
			-- Your setup opts here
		},
	},
}
