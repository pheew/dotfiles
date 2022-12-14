local buf_option = vim.api.nvim_buf_set_option

local lspconfig = require "lspconfig"

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

vim.diagnostic.config {
    virtual_text = false,
    severity_sort = true,
    float = {
        source = true,
        focus = false,
        format = function(diagnostic)
            if diagnostic.user_data ~= nil and diagnostic.user_data.lsp.code ~= nil then
                return string.format("%s: %s", diagnostic.user_data.lsp.code, diagnostic.message)
            end
            return diagnostic.message
        end
    }
}

local on_attach = function(_, bufnr)
    buf_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", {buffer = bufnr})
    vim.keymap.set("v", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>os", ":SymbolsOutline<CR>", {buffer = bufnr})
    vim.keymap.set("n", "<leader>of", ":Telescope lsp_document_symbols<CR>", {buffer = bufnr})

    vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local noConfigServers = {"bashls", "dockerls", "tsserver", "cssls", "graphql", "yamlls"}

for _, lsp in ipairs(noConfigServers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150
        }
    }
end

lspconfig.eslint.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
        debounce_text_changes = 150
    },
    handlers = {
        ["window/showMessageRequest"] = function(_, result, _)
            return result
        end
    }
}

lspconfig.jsonls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
        debounce_text_changes = 150
    },
    settings = {
        json = {
            schemas = require("schemastore").json.schemas()
        }
    }
}

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Setup your lua path
                path = runtime_path
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {"vim"}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false
            }
        }
    }
}
