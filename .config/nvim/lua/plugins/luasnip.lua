
return {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "1.*",
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    dependencies = {
        "honza/vim-snippets"
    },
    config = function()
        require("luasnip").config.set_config {
            history = true,
            updateevents = "TextChanged,TextChangedI"
        }
        require("luasnip.loaders.from_snipmate").lazy_load()
    end
}
