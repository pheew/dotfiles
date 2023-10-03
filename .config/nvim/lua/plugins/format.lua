return {
    -- Adds code formatting support
    {
        "sbdchd/neoformat",
        keys = {
            {
                "<leader>f",
                "<cmd>Neoformat<CR>",
                desc = "Format file",
                noremap = true,
                silent = true
            }
        }
    }
}
