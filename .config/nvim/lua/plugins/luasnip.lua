return {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "2.*",
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    dependencies = {
        "honza/vim-snippets"
    },
    opts = {
        history = true,
        delete_check_events = "TextChanged",
        updateevents = "TextChanged,TextChangedI"
    },
    keys = {
        {
            "<tab>",
            function()
                return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
        },
        { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
        { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
    config = function()
        local ls = require("luasnip")

        ls.filetype_extend("all", { "_" })

        require("luasnip.loaders.from_snipmate").lazy_load()
    end
}
