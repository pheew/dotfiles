return {
	-- Adds interactive help
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			preset = "helix",
			spec = {
				{ "<leader>g", group = "git" },
				{ "<leader>l", group = "lsp" },
				{ "<leader>o", group = "outline" },
				{ "<leader>q", group = "session" },
				{ "<leader>r", group = "refactor" },
				{ "<leader>s", group = "search" },
				{ "<leader>v", group = "vim config" },
			},
		},
		keys = {
			{
				"<leader>?",
				"<cmd>FzfLua keymaps<CR>",
				desc = "Search all keymaps",
			},
		},
	},
}
