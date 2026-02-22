return {
    "mfussenegger/nvim-dap-python",
    dependencies = {
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    -- stylua: ignore
    keys = {
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
        { "<leader>dC", function() require("dap").run_to_cursor() end,      desc = "Run to Cursor" },
        { "<leader>dT", function() require("dap").terminate() end,         desc = "Terminate" },
        { "<leader>du", function() require("dapui").toggle() end,          desc = "Toggle DAP UI" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        require("dap-python").setup("uv")

        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end
}
