vim.filetype.add(
    {
        extension = {
            ["test.ts"] = "typescript.jasmine",
            ["test.tsx"] = "typescriptreact.jasmine"
        },
        filename = {
            [".foorc"] = "foorc"
        },
        pattern = {
            [".*/etc/foo/.*%.conf"] = "foorc"
        }
    }
)
