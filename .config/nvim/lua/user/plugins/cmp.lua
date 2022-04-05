local cmp = require "cmp"
local lspkind = require "lspkind"

local luasnip = require "luasnip"

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,longest,preview"

cmp.setup {
    experimental = {
        ghost_text = true
    },
    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                nvim_lsp = "[LSP]",
                nvim_lua = "[Lua]",
                buffer = "[BUF]"
            }
        }
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    },
    mapping = {
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), {"i", "c"}),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), {"i", "c"}),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), {"i", "c"}),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-e>"] = cmp.mapping(
            {
                i = cmp.mapping.abort(),
                c = cmp.mapping.close()
            }
        ),
        ["<CR>"] = cmp.mapping.confirm({select = false, behavior = cmp.ConfirmBehavior.Insert}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end,
            {"i", "s"}
        ),
        ["<S-Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end,
            {"i", "s"}
        )
    },
    sources = {
        {name = "nvim_lsp"},
        {name = "nvim_lsp_signature_help"},
        {name = "nvim_lua"},
        {name = "luasnip"},
        {name = "path"},
        {name = "buffer"}
        -- { name = 'fuzzy_path' },
    }
}
