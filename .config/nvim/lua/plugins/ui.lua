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

	{ "lambdalisue/fern-hijack.vim" },
	-- File explorer
	{
		"lambdalisue/vim-fern",
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
				desc = "Open file explorer",
			},
		},
		init = function()
			vim.cmd([[
				let g:fern#renderer = "nerdfont"
				let g:fern#default_hidden = 1

				function! s:init_fern() abort
				  nmap <buffer> <C-n> <Plug>(fern-action-new-path)
				  nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
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

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
	},

	{
		"stevearc/oil.nvim",
		opts = {
			win_options = {
				wrap = false,
			},
			keymaps = {
				["l"] = { "actions.select", mode = "n" },
				["h"] = { "actions.parent", mode = "n" },
				["q"] = { "actions.close", mode = "n" },
			},
			float = {
				preview_split = "right",
				win_options = {},
			},
		},
		keys = {
			{
				"<leader>e",
				"<CMD>Oil --float<CR>",
				desc = "Open parent directory in oil.vnim",
			},
		},
		-- Optional dependencies
		-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	},

	-- Improve built-in vim UI
	-- {
	-- 	"stevearc/dressing.nvim",
	-- 	lazy = true,
	-- 	opts = {},
	-- 	init = function()
	-- 		---@diagnostic disable-next-line: duplicate-set-field
	-- 		vim.ui.select = function(...)
	-- 			require("lazy").load({ plugins = { "dressing.nvim" } })
	-- 			return vim.ui.select(...)
	-- 		end
	-- 		---@diagnostic disable-next-line: duplicate-set-field
	-- 		vim.ui.input = function(...)
	-- 			require("lazy").load({ plugins = { "dressing.nvim" } })
	-- 			return vim.ui.input(...)
	-- 		end
	-- 	end,
	-- },

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			-- dashboard = { enabled = true },
			-- explorer = { enabled = true },
			-- indent = { enabled = true },
			input = { enabled = true },
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
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
					-- component_separators = { left = " ", right = " " },
					-- section_separators = { left = '', right = ''},
				},
				extensions = {
					"fern",
					"fzf",
					"fugitive",
					"lazy",
					"oil",
					"trouble",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "filetype", "lsp_status" },
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
