return {
    {
        "mhartington/formatter.nvim",
        config = function()
            -- Global variable to track format-on-save state
            vim.g.format_on_save = true

            -- Helper function to check if command exists
            local function command_exists(cmd)
                local handle = io.popen("which " .. cmd .. " 2>/dev/null")
                if handle then
                    local result = handle:read("*a")
                    handle:close()
                    return result ~= ""
                end
                return false
            end

            -- Create fallback formatters with error handling
            local function create_formatter_with_fallback(primary, fallback,
                                                          filetype)
                return function()
                    if command_exists(primary.exe) then
                        return primary
                    elseif fallback and command_exists(fallback.exe) then
                        vim.notify(string.format(
                                       "Using fallback formatter %s for %s (primary %s not found)",
                                       fallback.exe, filetype, primary.exe),
                                   vim.log.levels.WARN)
                        return fallback
                    else
                        vim.notify(string.format(
                                       "No formatter available for %s (%s not found)",
                                       filetype, primary.exe),
                                   vim.log.levels.ERROR)
                        return nil
                    end
                end
            end

            require("formatter").setup({
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    lua = {
                        create_formatter_with_fallback({
                            exe = "lua-format",
                            args = {"-i"},
                            stdin = true
                        }, {
                            exe = "stylua",
                            args = {"--stdin-filepath", "%", "-"},
                            stdin = true
                        }, "lua")
                    },
                    javascript = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {
                                "--parser", "babel", "--stdin-filepath", "%"
                            },
                            stdin = true
                        }, {
                            exe = "deno",
                            args = {"fmt", "--stdin-filepath", "%", "-"},
                            stdin = true
                        }, "javascript")
                    },
                    javascriptreact = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {
                                "--parser", "babel", "--stdin-filepath", "%"
                            },
                            stdin = true
                        }, {
                            exe = "deno",
                            args = {"fmt", "--stdin-filepath", "%", "-"},
                            stdin = true
                        }, "javascriptreact")
                    },
                    typescript = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {
                                "--parser", "typescript", "--stdin-filepath",
                                "%"
                            },
                            stdin = true
                        }, {
                            exe = "deno",
                            args = {"fmt", "--stdin-filepath", "%", "-"},
                            stdin = true
                        }, "typescript")
                    },
                    typescriptreact = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {
                                "--parser", "typescript", "--stdin-filepath",
                                "%"
                            },
                            stdin = true
                        }, {
                            exe = "deno",
                            args = {"fmt", "--stdin-filepath", "%", "-"},
                            stdin = true
                        }, "typescriptreact")
                    },
                    json = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "json"},
                            stdin = true
                        }, {exe = "jq", args = {"."}, stdin = true}, "json")
                    },
                    html = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "html"},
                            stdin = true
                        }, {
                            exe = "tidy",
                            args = {"-indent", "-quiet", "--show-errors", "0"},
                            stdin = true
                        }, "html")
                    },
                    css = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "css"},
                            stdin = true
                        }, nil, "css")
                    },
                    scss = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "scss"},
                            stdin = true
                        }, nil, "scss")
                    },
                    ruby = {
                        create_formatter_with_fallback({
                            exe = "rubocop",
                            args = {
                                "--auto-correct", "--stdin", "%", "--stderr"
                            },
                            stdin = true
                        }, {exe = "rufo", args = {}, stdin = true}, "ruby")
                    },
                    rust = {
                        create_formatter_with_fallback({
                            exe = "rustfmt",
                            args = {"--edition 2021"},
                            stdin = true
                        }, nil, "rust")
                    },
                    cpp = {
                        create_formatter_with_fallback({
                            exe = "clang-format",
                            args = {},
                            stdin = true
                        }, {
                            exe = "uncrustify",
                            args = {"-c", "~/.uncrustify.cfg"},
                            stdin = true
                        }, "cpp")
                    },
                    c = {
                        create_formatter_with_fallback({
                            exe = "clang-format",
                            args = {},
                            stdin = true
                        }, {
                            exe = "uncrustify",
                            args = {"-c", "~/.uncrustify.cfg"},
                            stdin = true
                        }, "c")
                    },
                    python = {
                        create_formatter_with_fallback({
                            exe = "ruff",
                            args = {"format", "--stdin-filename", "%", "-"},
                            stdin = true
                        }, {
                            exe = "black",
                            args = {"--quiet", "-"},
                            stdin = true
                        }, "python")
                    },
                    go = {
                        create_formatter_with_fallback({
                            exe = "gofmt",
                            args = {},
                            stdin = true
                        }, {exe = "goimports", args = {}, stdin = true}, "go")
                    },
                    yaml = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "yaml"},
                            stdin = true
                        },
                                                       {
                            exe = "yq",
                            args = {"eval", ".", "-"},
                            stdin = true
                        }, "yaml")
                    },
                    markdown = {
                        create_formatter_with_fallback({
                            exe = "prettier",
                            args = {"--parser", "markdown"},
                            stdin = true
                        }, nil, "markdown")
                    },
                    sh = {
                        create_formatter_with_fallback({
                            exe = "shfmt",
                            args = {"-i", "2"},
                            stdin = true
                        }, {
                            exe = "shellharden",
                            args = {"--replace"},
                            stdin = false
                        }, "sh")
                    },
                    xml = {
                        create_formatter_with_fallback({
                            exe = "xmllint",
                            args = {"--format", "-"},
                            stdin = true
                        }, {
                            exe = "tidy",
                            args = {
                                "-xml", "-indent", "-quiet", "--show-errors",
                                "0"
                            },
                            stdin = true
                        }, "xml")
                    },
                    ["*"] = {
                        require("formatter.filetypes.any").remove_trailing_whitespace
                    }
                }
            })

            -- Enhanced format function with better error handling
            local function safe_format()
                local filetype = vim.bo.filetype
                local filename = vim.fn.expand("%:t")

                -- Skip formatting for certain filetypes
                local skip_filetypes = {
                    "help", "terminal", "alpha", "dashboard", "NvimTree",
                    "Trouble", "lir"
                }
                if vim.tbl_contains(skip_filetypes, filetype) then
                    return
                end

                local success, error_msg = pcall(function()
                    vim.api.nvim_command("FormatWrite")
                end)

                if not success then
                    if error_msg:match("no formatters configured") then
                        vim.notify(string.format(
                                       "No formatter configured for %s files",
                                       filetype), vim.log.levels.INFO)
                    elseif error_msg:match("command not found") or
                        error_msg:match("not found") then
                        vim.notify(string.format(
                                       "Formatter command not found for %s",
                                       filename), vim.log.levels.WARN)
                    else
                        vim.notify(
                            string.format("Formatting failed for %s: %s",
                                          filename, error_msg),
                            vim.log.levels.ERROR)
                    end
                end
            end

            -- Format on save autocommand with enhanced error handling
            local format_group = vim.api.nvim_create_augroup("FormatAutogroup",
                                                             {clear = true})
            vim.api.nvim_create_autocmd("BufWritePost", {
                group = format_group,
                callback = function()
                    if vim.g.format_on_save then
                        safe_format()
                    end
                end
            })

            -- Create FormatToggle command
            vim.api.nvim_create_user_command("FormatToggle", function()
                vim.g.format_on_save = not vim.g.format_on_save
                local state = vim.g.format_on_save and "enabled" or "disabled"
                vim.notify("Format on save " .. state, vim.log.levels.INFO)
            end, {desc = "Toggle format on save"})

            -- Enhanced Format command
            vim.api.nvim_create_user_command("Format",
                                             function() safe_format() end,
                                             {desc = "Format current buffer"})

            -- Command to check available formatters
            vim.api.nvim_create_user_command("FormatCheck", function()
                local filetype = vim.bo.filetype
                local formatters = {
                    lua = {"lua-format", "stylua"},
                    javascript = {"prettier", "deno"},
                    typescript = {"prettier", "deno"},
                    json = {"prettier", "jq"},
                    html = {"prettier", "tidy"},
                    css = {"prettier"},
                    python = {"ruff", "black", "autopep8"},
                    rust = {"rustfmt"},
                    go = {"gofmt", "goimports"},
                    cpp = {"clang-format", "uncrustify"},
                    c = {"clang-format", "uncrustify"},
                    ruby = {"rubocop", "rufo"},
                    yaml = {"prettier", "yq"},
                    markdown = {"prettier"},
                    sh = {"shfmt", "shellharden"},
                    xml = {"xmllint", "tidy"}
                }

                local available = {}
                local missing = {}

                if formatters[filetype] then
                    for _, cmd in ipairs(formatters[filetype]) do
                        if command_exists(cmd) then
                            table.insert(available, cmd)
                        else
                            table.insert(missing, cmd)
                        end
                    end

                    local msg = string.format("Formatters for %s:\n", filetype)
                    if #available > 0 then
                        msg = msg .. "✅ Available: " ..
                                  table.concat(available, ", ") .. "\n"
                    end
                    if #missing > 0 then
                        msg = msg .. "❌ Missing: " ..
                                  table.concat(missing, ", ")
                    end

                    vim.notify(msg, vim.log.levels.INFO)
                else
                    vim.notify("No formatters configured for " .. filetype,
                               vim.log.levels.WARN)
                end
            end, {desc = "Check available formatters for current filetype"})
        end
    }
}
