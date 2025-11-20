return {
	-- Adds code formatting support
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		dependencies = { "mason.nvim" },
		lazy = true,
		cmd = { "ConformInfo", "Format" },
		config = function(opts)
			-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#format-command
			vim.api.nvim_create_user_command("Format", function(args)
				local range = nil
				if args.count ~= -1 then
					local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
					range = {
						start = { args.line1, 0 },
						["end"] = { args.line2, end_line:len() },
					}
				end
				require("conform").format({ async = true, lsp_format = "fallback", range = range })
			end, { range = true })

			require("conform").setup(opts)
		end,
		keys = {
			{
				"<leader>f",
				"<cmd>Format<CR>",
				desc = "format buffer",
				noremap = true,
				silent = false,
			},
		},
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				shell = { "shfmt" },
				sh = { "shfmt" },
				lua = { "stylua" },
				javascript = { "prettierd", "prettier" },
				javascriptreact = { "prettierd", "prettier" },
				typescript = { "prettierd", "prettier" },
				typescriptreact = { "prettierd", "prettier" },
				vue = { "prettierd", "prettier" },
				css = { "prettierd", "prettier" },
				scss = { "prettierd", "prettier" },
				less = { "prettierd", "prettier" },
				html = { "prettierd", "prettier" },
				json = { "prettierd", "prettier", "jq" },
				jsonc = { "prettierd", "prettier" },
				yaml = { "prettierd", "prettier" },
				markdown = { "prettierd", "prettier" },
				["markdown.mdx"] = { "prettierd", "prettier" },
				graphql = { "prettierd", "prettier" },
				handlebars = { "prettierd", "prettier" },
			},
		},
	},
}
