-- Use treesitter for syntax highlighting
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSUpdateSync" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"typescript",
				"lua",
				"go",
				"javascript",
				"html",
				"yaml",
				"json",
				"css",
				"scss",
				"fish",
				"bash",
			},
			indent = {
				enable = { "lua", "html", "blade" },
			},
			highlight = {
				enable = true,
				disable = { "fern", "alpha" },
				--additional_vim_regex_highlighting = true,
			},
		})

	end,
}
