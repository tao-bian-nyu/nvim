return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 2026 Modern UI style
    preset = "icons", 
    spec = {
      { "<leader>d", group = "󰃤 Debug" },
      { "<leader>g", group = "󰘦 LSP" },
      { "<leader>p", group = " Python" },
      { "<leader>f", group = " Telescope" },
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
