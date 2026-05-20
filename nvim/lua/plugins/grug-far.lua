return {
    "MagicDuck/grug-far.nvim",
    keys = {
        { "<leader>sr", function() require("grug-far").open() end, desc = "Search and replace (project)" },
        {
            "<leader>sw",
            function()
                require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
            end,
            desc = "Search current word"
        },
    },
    opts = {},
}
