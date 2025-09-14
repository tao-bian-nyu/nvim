vim.g.mapleader = " " -- Set leader key before Lazy
vim.g.maplocalleader = " "
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

require ("config.lazy")

require ("config.options")

-- vim.cmd.colorscheme("tokyonight")
vim.cmd.colorscheme("catppuccin-macchiato")

require ("config.maps")

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', {}),
  desc = 'Hightlight selection on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 }
  end,
})
