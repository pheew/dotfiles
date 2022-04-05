require("nvim-treesitter.configs").setup {
    ensure_installed = "maintained",
    indent = {
        enable = {"lua", "html", "blade"}
    },
    highlight = {
        enable = true,
        disable = {"fern"}
        --additional_vim_regex_highlighting = true,
    }
}
