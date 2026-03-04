return {
    {"mason-org/mason.nvim", opts = {}}, {
        "neovim/nvim-lspconfig",
        dependencies = {"hrsh7th/cmp-nvim-lsp"},
        config = function()
            local opts = {noremap = true, silent = true}

            -- Global mappings
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[g', function()
                vim.diagnostic.jump({count = -1, float = true})
            end, opts)
            vim.keymap.set('n', ']g', function()
                vim.diagnostic.jump({count = 1, float = true})
            end, opts)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            -- Use LspAttach autocmd for buffer-local keymaps
            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local client = vim.lsp
                                       .get_client_by_id(event.data.client_id)
                    local bufnr = event.buf

                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    -- Disable formatting for specific LSPs (we use formatter.nvim)
                    if client.name == "ts_ls" or client.name == "html" or
                        client.name == "jsonls" or client.name == "yamlls" or
                        client.name == "cssls" then
                        client.server_capabilities.documentFormattingProvider =
                            false
                        client.server_capabilities
                            .documentRangeFormattingProvider = false
                    end

                    -- Buffer-local mappings
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs,
                                       {buffer = bufnr, desc = desc})
                    end

                    -- Navigation
                    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
                    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
                    map('n', 'gt',
                        '<cmd>lua require(\'lsp\').definition_new_tab()<CR>',
                        'Go to definition in new tab')
                    map('n', 'gv',
                        '<cmd>lua require(\'lsp\').definition_vsplit()<CR>',
                        'Go to definition in vsplit')

                    -- Documentation
                    map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
                    map('n', 'gK', vim.lsp.buf.signature_help, 'Signature help')

                    -- Workspace
                    map('n', '<space>wa', vim.lsp.buf.add_workspace_folder,
                        'Add workspace folder')
                    map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
                        'Remove workspace folder')
                    map('n', '<space>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, 'List workspace folders')

                    -- Types and refactoring
                    map('n', '<space>D', vim.lsp.buf.type_definition,
                        'Type definition')
                    map('n', '<space>rn', vim.lsp.buf.rename, 'Rename')
                    map('n', '<space>ca', vim.lsp.buf.code_action, 'Code action')

                    -- Formatting
                    map('n', '<space>f',
                        function()
                        vim.lsp.buf.format({async = true})
                    end, 'Format buffer')

                    -- Document highlights
                    map('n', '<space>j', vim.lsp.buf.document_highlight,
                        'Highlight references')
                    map('n', '<space>k', vim.lsp.buf.clear_references,
                        'Clear references')
                end
            })

            -- LSP capabilities with completion support
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Set completion options
            vim.opt.completeopt = {"menu", "menuone", "noselect"}

            vim.lsp.config('rust_analyzer', {
                cmd = {'rust-analyzer'},
                root_markers = {'Cargo.toml'},
                capabilities = capabilities
            })

            vim.lsp.enable('rust_analyzer')

            -- tailwindcss: NativeWind support
            require("lspconfig").tailwindcss.setup({
                capabilities = capabilities,
                filetypes = {
                    "javascript", "javascriptreact",
                    "typescript", "typescriptreact",
                },
                settings = {
                    tailwindCSS = {
                        experimental = {
                            classRegex = {
                                { [[className\s*=\s*["'`]([^"'`]*)["'`]]] },
                                { [[tw`([^`]*)]] },
                                { [[cn\(([^)]*)\)]], [["([^"]*)"]] },
                            },
                        },
                        validate = true,
                    },
                },
                root_dir = require("lspconfig.util").root_pattern(
                    "tailwind.config.js", "tailwind.config.ts",
                    "tailwind.config.cjs", "nativewind-env.d.ts",
                    "nativewind.config.ts"
                ),
            })

            -- cssls: StyleSheet CSS property completions
            require("lspconfig").cssls.setup({
                capabilities = capabilities,
            })

            -- jsonls: schema completions via schemastore
            require("lspconfig").jsonls.setup({
                capabilities = capabilities,
                settings = {
                    json = {
                        schemas = require("schemastore").json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            -- Enhanced diagnostics configuration
            vim.diagnostic.config({
                virtual_text = {prefix = "●", spacing = 4, source = "if_many"},
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = ""
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = "󰠠 "
                    },
                    linehl = {
                        [vim.diagnostic.severity.ERROR] = "DiagnosticLineNrError",
                        [vim.diagnostic.severity.WARN] = "DiagnosticLineNrWarn",
                        [vim.diagnostic.severity.INFO] = "DiagnosticLineNrInfo",
                        [vim.diagnostic.severity.HINT] = "DiagnosticLineNrHint"
                    },
                    numhl = {
                        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint"
                    }
                },
                update_in_insert = false,
                underline = true,
                severity_sort = true
            })

        end
    }, {
        "mason-org/mason-lspconfig.nvim",
        opts = {ensure_installed = {"lua_ls", "ts_ls", "tailwindcss", "cssls", "jsonls"}},
        dependencies = {{"mason-org/mason.nvim"}, "neovim/nvim-lspconfig"}
    }, {"b0o/schemastore.nvim", lazy = true}
}
