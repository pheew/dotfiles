-- Adds Language Server Protocol config

local border = "rounded"

return {
	{ -- Better lua neovim API support
		"folke/lazydev.nvim",
		dependencies = {
			{ "Bilal2453/luvit-meta", lazy = true },
		},
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	-- Useful status updates for LSP
	-- {
	-- 	"j-hui/fidget.nvim",
	-- 	dependencies = {
	-- 		"neovim/nvim-lspconfig",
	-- 	},
	-- 	branch = "main",
	-- 	opts = {
	-- 		notification = {
	-- 			window = {
	-- 				border = border,
	-- 			},
	-- 		},
	-- 	},
	-- },
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"hrsh7th/nvim-cmp",
			"b0o/schemastore.nvim",

			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true, cmd = "Mason" },
			"williamboman/mason-lspconfig.nvim",
		},
		keys = {
			{
				"<leader>lr",
				"<cmd>LspRestart<CR>",
				desc = "Restart LSP Server",
				noremap = true,
				silent = true,
			},

			{
				"<leader>li",
				"<cmd>LspInfo<CR>",
				desc = "LSP Server Info",
				noremap = true,
				silent = true,
			},
		},
		config = function()
			vim.diagnostic.config({
				float = { border = border },
			})

			local servers = {
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				fish_lsp = {},
				azure_pipelines_ls = {},
				eslint = {},
				jsonls = {},
				bashls = {},
				dockerls = {},
				ts_ls = {},
				html = { filetypes = { "html", "twig", "hbs" } },
				-- react = {},
				cssls = {},
				graphql = {},
				lua_ls = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			}

			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Ensure the servers above are installed
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_enable = true,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					-- Unset 'formatexpr'
					vim.bo[args.buf].formatexpr = nil
					-- Unset 'omnifunc'
					vim.bo[args.buf].omnifunc = nil
					-- Unmap K
					vim.keymap.del("n", "K", { buffer = args.buf })

					local bufnr = args.buf

					vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

					vim.keymap.set("n", "gD", "<cmd>FzfLua lsp_declarations<CR>", { buffer = bufnr, desc = "Go to Declaration" })
					vim.keymap.set(
						"n",
						"gd",
						"<cmd>FzfLua lsp_definitions jump_to_single_result=true<CR>",
						{ buffer = bufnr, desc = "Go to Definition" }
					)
					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = bufnr })
					vim.keymap.set(
						"n",
						"gi",
						"<cmd>FzfLua lsp_implementations<CR>",
						{ buffer = bufnr, desc = "Go to Implementation" }
					)
					vim.keymap.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { buffer = bufnr })
					vim.keymap.set(
						"n",
						"<leader>D",
						"<cmd>FzfLua lsp_typedefs<CR>",
						{ buffer = bufnr, desc = "Show type definition" }
					)
					vim.keymap.set(
						"n",
						"<leader>rn",
						"<cmd>lua vim.lsp.buf.rename()<CR>",
						{ buffer = bufnr, desc = "Rename symbol" }
					)
					vim.keymap.set("n", "gr", ":FzfLua lsp_references<CR>", { buffer = bufnr, desc = "Go to references" })
					vim.keymap.set(
						{ "n", "v" },
						"<leader>ra",
						"<cmd>lua vim.lsp.buf.code_action()<CR>",
						{ buffer = bufnr, desc = "Code Actions" }
					)
					-- Disabled because I'm using trouble.nvim for this
					-- vim.keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", { buffer = bufnr })
					-- vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { buffer = bufnr })
					-- vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", { buffer = bufnr })
					vim.keymap.set(
						"n",
						"<leader>of",
						"<cmd>FzfLua lsp_document_symbols<CR>",
						{ buffer = bufnr, desc = "Jump to document symbol" }
					)
				end,
			})

			-- mason_lspconfig.setup_handlers({
			-- 	function(server_name)
			-- 		require("lspconfig")[server_name].setup({
			-- 			capabilities = capabilities,
			-- 			on_attach = on_attach,
			-- 			settings = servers[server_name],
			-- 			filetypes = (servers[server_name] or {}).filetypes,
			-- 		})
			-- 	end,
			-- })
		end,
	},
}
