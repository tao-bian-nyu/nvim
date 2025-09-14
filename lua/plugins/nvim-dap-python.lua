return {
    "mfussenegger/nvim-dap-python",
    -- stylua: ignore
    keys = {

        {
            "<leader>db",
            function() require("dap").toggle_breakpoint() end,
            desc = "Toggle Breakpoint"
        },

        {
            "<leader>dc",
            function() require("dap").continue() end,
            desc = "Continue"
        },

        {
            "<leader>dC",
            function() require("dap").run_to_cursor() end,
            desc = "Run to Cursor"
        },

        {
            "<leader>dT",
            function() require("dap").terminate() end,
            desc = "Terminate"
        },
    },
    config = function()
        require("dap-python").setup("uv")
    end
}
