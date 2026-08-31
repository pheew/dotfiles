return {
	{
		"github/copilot.vim"
	},
	{
		"azorng/goose.nvim",
		config = function()
			require("goose").setup({
				keymap = {
					global = {},
					window = {},
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					anti_conceal = { enabled = false },
				},
			},
		},
	},
}
