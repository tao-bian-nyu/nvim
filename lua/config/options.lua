local set = vim.opt

-- -- terminal settings
-- local powershell_options = {
--   shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
--   shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
--   shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
--   shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
--   shellquote = "",
--   shellxquote = "",
-- }
--
-- for option, value in pairs(powershell_options) do
--   set[option] = value
-- end

-- set.guicursor = "" -- thick cursor in insert mode

-- if vim.loop.os_uname().sysname == "Linux" then
--   set.background = "dark"
-- elseif vim.loop.os_uname().sysname == "Darwin" then
--   set.background = "light"
-- end

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

set.termguicolors = true

set.nu = true
set.relativenumber = true
set.cursorline = true

set.signcolumn = "yes"
set.scrolloff = 3
set.sidescrolloff = 8

set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
-- set.colorcolumn = "90"

set.expandtab = true

set.virtualedit = "block"

set.inccommand = "split"

-- search settings
set.hlsearch = false
set.incsearch = true
set.ignorecase = true
set.smartcase = true
set.hidden = true

-- set.autoindent = true
set.smartindent = true

set.backspace = "indent,eol,start"

set.iskeyword:append("-")
set.mouse = 'a'

set.wrap = false

set.cmdheight = 1

set.showcmd = false

set.completeopt = "menu,menuone,noselect"

set.clipboard:append("unnamedplus")

-- split windows
set.splitright = true
set.splitbelow = true


-- vim.o.updatetime = 250
-- vim.o.timeout = true
-- vim.o.timeoutlen = 300


vim.filetype.add({
  extension = {
    ["http"] = "http",
    jinja = "jinja",
    jinja2 = "jinja",
    j2 = "jinja",
  },
})
