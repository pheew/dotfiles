return {
	"tpope/vim-sleuth", -- Indent autodetection with editorconfig support
	"tpope/vim-surround", -- Change surrounding braces easily

	-- Search
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "kyazdani42/nvim-web-devicons" },
		cmd = "FzfLua",
		opts = {
			"fzf-tmux",
			winopts = {
				backdrop = false,
				preview = {
					border = "border-left",
					default = "bat",
				},
			},
			fzf_opts = {
				["--layout"] = "default",
			},
		},
		keys = {
			{
				"<C-p>",
				"<cmd>FzfLua files<CR>",
				desc = "Find file in project",
			},
			{
				";",
				"<cmd>FzfLua buffers<CR>",
				desc = "Buffer list",
			},
			{
				"<S-f>",
				"<cmd>FzfLua live_grep_glob<CR>",
				desc = "Find in project",
			},
			{
				"<leader>h",
				"<cmd>FzfLua oldfiles<CR>",
				desc = "Show history",
			},
			{
				"<S-l>",
				"<cmd>FzfLua builtin<CR>",
				desc = "Builtin lists",
			},
			{
				"<leader>lr",
				"<cmd>FzfLua resume<CR>",
				desc = "Resume FzfLua",
			},
			{
				"<leader>?",
				"<cmd>FzfLua helptags<CR>",
				desc = "Search help tags",
			},
		},
	},

	-- search/replace in multiple files
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		opts = {},
		keys = {
			{
				"<leader>sr",
				function()
					require("grug-far").open()
				end,
				desc = "Replace in files (GrugFar)",
			},
		},
	},

	-- color highlighting
	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPre",
		opts = {},
	},

	-- Comments
	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	-- Jumping around
	{
		"ggandor/leap.nvim",
		enabled = true,
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
	},
}
