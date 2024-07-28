return {
	-- Adds git integration
	{
		"tpope/vim-fugitive",
		dependencies = {
			"tpope/vim-rhubarb",
			{
				"sindrets/diffview.nvim",
				event = "VeryLazy",
				dependencies = {
					"nvim-lua/plenary.nvim",
				},
				keys = {
					{
						"<leader>gf",
						"<cmd>DiffviewFileHistory %<CR>",
						desc = "View file history",
						noremap = true,
					},

					{
						"<leader>gd",
						":DiffviewOpen",
						desc = "View history",
						noremap = true,
					},
				},
			},
		},

		-- cmd = "G",
		lazy = false,
		keys = {
			{
				"<leader>gr",
				":GBrowse!",
				mode = { "n", "v" },
				desc = "Browse repo",
			},
			{
				"<leader>gs",
				":G<CR>",
				desc = "Open Git summary",
			},
			{
				"<leader>gb",
				":Git blame<CR>",
				desc = "Git blame",
			},
		},
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			preview_config = {
				-- Options passed to nvim_open_win
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			on_attach = function(bufnr)
				vim.keymap.set(
					"n",
					"<leader>hp",
					require("gitsigns").preview_hunk,
					{ buffer = bufnr, desc = "Preview git hunk" }
				)

				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
			end,
		},
	},
}
