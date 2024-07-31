-- Use treesitter for syntax highlighting
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSUpdateSync" },
	dependencies = {
		"nvim-treesitter/playground",
		"nvim-treesitter/nvim-treesitter-textobjects",
		"lewis6991/spellsitter.nvim",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "typescript", "lua", "go", "javascript", "html", "yaml", "json" },
			indent = {
				enable = { "lua", "html", "blade" },
			},
			highlight = {
				enable = true,
				disable = { "fern", "alpha" },
				--additional_vim_regex_highlighting = true,
			},
		})

		require("spellsitter").setup()
	end,
}
