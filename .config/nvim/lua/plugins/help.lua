return {
	-- Adds searchable cheatsheet
	{
		"sudormrfbin/cheatsheet.nvim",
		cmd = "Cheatsheet",
		dependencies = {
			-- { "nvim-telescope/telescope.nvim" },
		},
	},

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
				{ "<leader>q", group = "session" },
			},
		},
	},
}
