return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 2026 Modern UI style
    preset = "icons", 
    spec = {
      { "<leader>d", group = "󰃤 Debug" },
      { "<leader>l", group = "󰘦 LSP" },
      { "<leader>p", group = " Python" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Local Keymaps (Which Key)",
    },
  },
}
