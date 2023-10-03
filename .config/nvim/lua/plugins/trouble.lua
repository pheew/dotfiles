return {
    -- Trouble
    {
        "folke/trouble.nvim",
        cmd = {"TroubleToggle", "Trouble"},
        dependencies = "kyazdani42/nvim-web-devicons",
        keys = {
            {
                -- Show Trouble screen
                "<leader>t",
                "<cmd>Trouble document_diagnostics<CR>"
            },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").previous({skip_groups = true, jump = true})
                    else
                        local ok, err = pcall(vim.cmd.cprev)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Previous trouble/quickfix item"
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({skip_groups = true, jump = true})
                    else
                        local ok, err = pcall(vim.cmd.cnext)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Next trouble/quickfix item"
            }
        }
    }
}
