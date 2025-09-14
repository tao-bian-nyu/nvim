return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        require('mason').setup()
        local mason_lspconfig = require 'mason-lspconfig'
        mason_lspconfig.setup {
            ensure_installed = {
                "pyright",
                "ruff",
                "lua_ls"
            }
        }

        -- Auto-detect Python interpreter (.venv > VIRTUAL_ENV > pyenv > system)
        local function get_python_path()
            local cwd = vim.fn.getcwd()
            local venv_python = cwd .. "/.venv/bin/python"
            if vim.fn.filereadable(venv_python) == 1 then
                return venv_python
            end

            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
                return venv .. "/bin/python"
            end

            local pyenv_version = os.getenv("PYENV_VERSION")
            if pyenv_version then
                return os.getenv("HOME") .. "/.pyenv/versions/" .. pyenv_version .. "/bin/python"
            end

            return "/usr/bin/python3"
        end

        -- Global patch for workspace edits to handle changeAnnotations issues
        local orig_apply = vim.lsp.util.apply_workspace_edit
        vim.lsp.util.apply_workspace_edit = function(edit, client)
            -- Fix for both Ruff and Pyright changeAnnotations issues
            if edit.documentChanges then
                for _, doc_change in ipairs(edit.documentChanges) do
                    if doc_change.edits then
                        for _, e in ipairs(doc_change.edits) do
                            -- Remove annotationId if changeAnnotations is not provided
                            if e.annotationId and not edit.changeAnnotations then
                                e.annotationId = nil
                            end
                        end
                    end
                end
            end
            return orig_apply(edit, client)
        end

        -- Configure pyright
        require("lspconfig").pyright.setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
            end,
            handlers = {
                -- Override the default rename handler to remove the `annotationId` from edits.
                [vim.lsp.protocol.Methods.textDocument_rename] = function(err, result, ctx)
                    if err then
                        vim.notify('Pyright rename failed: ' .. err.message, vim.log.levels.ERROR)
                        return
                    end

                    ---@cast result lsp.WorkspaceEdit
                    if result.documentChanges then
                        for _, change in ipairs(result.documentChanges) do
                            if change.edits then
                                for _, edit in ipairs(change.edits) do
                                    if edit.annotationId then
                                        edit.annotationId = nil
                                    end
                                end
                            end
                        end
                    end

                    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
                    vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
                end,
            },
            settings = {
                python = {
                    pythonPath = get_python_path(),
                    analysis = {
                        typeCheckingMode = "basic",       -- Changed from "off" to get some type checking
                        diagnosticMode = "openFilesOnly", -- Changed from "off"
                        -- Disable overlapping diagnostics that Ruff handles better
                        diagnosticSeverityOverrides = {
                            reportUnusedImport = "none",
                            reportUnusedVariable = "none",
                            reportDuplicateImport = "none",
                        },
                    },
                },
            },
        })

        -- Ruff setup: diagnostics only (safe, no change_annotations error)
        require("lspconfig").ruff.setup({
            cmd = { "ruff", "server" }, -- use latest Ruff CLI LSP
            capabilities = capabilities,
            init_options = {
                settings = {
                    args = {},
                },
            },
            on_attach = function(client, bufnr)
                client.server_capabilities.hoverProvider = false
            end,
            -- Add handlers to fix changeAnnotations issues
            handlers = {
                [vim.lsp.protocol.Methods.textDocument_codeAction] = function(err, result, ctx)
                    if err then
                        return
                    end

                    -- Clean up any problematic annotations
                    if result then
                        for _, action in ipairs(result) do
                            if action.edit and action.edit.documentChanges then
                                for _, change in ipairs(action.edit.documentChanges) do
                                    if change.edits then
                                        for _, edit in ipairs(change.edits) do
                                            if edit.annotationId and not action.edit.changeAnnotations then
                                                edit.annotationId = nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_codeAction](err, result, ctx)
                end,
            },

        })

        -- Configure lua_ls if needed
        require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })

        -- Enhanced auto-formatting and auto-fixing on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.py",
            callback = function()
                vim.lsp.buf.format({
                    timeout_ms = 2000,
                    filter = function(client)
                        -- Only use Ruff for formatting
                        return client.name == "ruff"
                    end
                })
            end,
        })

        -- Enhanced diagnostic configuration optimized for Ruff
        vim.diagnostic.config({
            virtual_text = {
                enabled = true,
                source = "if_many",
                spacing = 2,
                prefix = function(diagnostic, i, total)
                    -- Different icons for different severities
                    local icons = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                    }
                    return icons[diagnostic.severity] or "●"
                end,
                format = function(diagnostic)
                    -- Show Ruff rule codes for better understanding
                    local message = diagnostic.message
                    if diagnostic.source == "ruff" and diagnostic.code then
                        return string.format("%s (%s)", message, diagnostic.code)
                    end
                    return message
                end,
            },

            float = {
                enabled = true,
                source = "always",
                border = "rounded",
                header = "",
                prefix = function(diagnostic, i, total)
                    local icons = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                    }
                    return icons[diagnostic.severity] or "●",
                        "DiagnosticFloating" .. vim.diagnostic.severity[diagnostic.severity]
                end,
                format = function(diagnostic)
                    local message = diagnostic.message
                    if diagnostic.source == "ruff" and diagnostic.code then
                        return string.format("%s\n\nRule: %s", message, diagnostic.code)
                    end
                    return message
                end,
            },

            signs = {
                enabled = true,
                priority = 10,
            },

            underline = {
                enabled = true,
                severity = nil,
            },

            update_in_insert = false,
            severity_sort = true,
        })

        -- Enhanced diagnostic signs with better icons
        local signs = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = " "
        }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, {
                text = icon,
                texthl = hl,
                numhl = hl
            })
        end
    end
}
