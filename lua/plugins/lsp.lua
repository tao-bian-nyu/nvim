return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        require('mason').setup()
        local mason_lspconfig = require('mason-lspconfig')

        -- 1. fix rename
        local function fix_edits(edit)
            if edit and edit.documentChanges then
                for _, change in ipairs(edit.documentChanges) do
                    for _, e in ipairs(change.edits or {}) do
                        if e.annotationId then e.annotationId = nil end
                    end
                end
            end
            return edit
        end

        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        mason_lspconfig.setup({
            ensure_installed = { "pyright", "ruff", "lua_ls" },
            handlers = {
                -- 默认配置函数
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                -- Pyright
                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        capabilities = capabilities,
                        handlers = {
                            [vim.lsp.protocol.Methods.textDocument_rename] = function(err, result, ctx)
                                return vim.lsp.handlers[ctx.method](err, fix_edits(result), ctx)
                            end,
                        },
                    })
                end,

                -- Ruff
                ["ruff"] = function()
                    require("lspconfig").ruff.setup({
                        capabilities = capabilities,
                        on_attach = function(client)
                            client.server_capabilities.hoverProvider = false
                        end,
                        handlers = {
                            [vim.lsp.protocol.Methods.textDocument_codeAction] = function(err, result, ctx)
                                if result then
                                    for _, action in ipairs(result) do
                                        fix_edits(action.edit)
                                    end
                                end
                                return vim.lsp.handlers[ctx.method](err, result, ctx)
                            end,
                        },
                    })
                end,

                -- Lua
                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = { globals = { 'vim' } },
                                workspace = { checkThirdParty = false }
                            }
                        }
                    })
                end,
            }
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.py",
            callback = function()
                vim.lsp.buf.format({
                    timeout_ms = 2000,
                    filter = function(c) return c.name == "ruff" end
                })
            end,
        })

        vim.diagnostic.config({
            virtual_text = {
                prefix = "●",
                format = function(d)
                    return d.source == "ruff" and string.format("%s (%s)", d.message, d.code) or d.message
                end
            },
            float = { border = "rounded", source = "always" },
            severity_sort = true,
        })
    end
}
