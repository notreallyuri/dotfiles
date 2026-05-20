return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        priority = 1000,
        opts = {
            preset = "modern",
            options = {
                show_source = true,
                multiple_diag_under_cursor = true,
                multilines = true,
            },
        },
        config = function(_, opts)
            require("tiny-inline-diagnostic").setup(opts)
            vim.diagnostic.config({ virtual_text = false })
        end,
    },
}
