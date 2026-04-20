return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash", "c", "cpp", "css", "dockerfile", "go", "html",
                    "javascript", "json", "lua", "markdown", "markdown_inline",
                    "python", "regex", "ruby", "rust", "tsx", "typescript",
                    "vim", "vimdoc", "yaml",
                },
                highlight = { enable = true },
                indent = {
                    enable = true,
                    disable = { "python", "yaml" },
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        node_decremental = "grm",
                        scope_incremental = "grc",
                    },
                },
            })

            vim.opt.foldenable = false
            vim.opt.foldlevel = 99
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

            -- Custom highlights
            local function set_custom_highlights()
                local colors = vim.g
                if colors.terminal_color_12 and colors.terminal_color_14 then
                    local highlights = {
                        ["@tag.tsx"] = { fg = colors.terminal_color_12 },
                        ["@tag.attribute.tsx"] = { fg = colors.terminal_color_14 },
                        ["@constructor.tsx"] = { fg = colors.terminal_color_12 },
                        ["@constructor.ts"] = { fg = colors.terminal_color_12 },
                        ["@tag.javascript"] = { fg = colors.terminal_color_12 },
                        ["@tag.attribute.javascript"] = { fg = colors.terminal_color_14 },
                        ["@constructor.javascript"] = { fg = colors.terminal_color_12 },
                    }
                    for group, opts in pairs(highlights) do
                        vim.api.nvim_set_hl(0, group, opts)
                    end
                end
            end

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = set_custom_highlights,
                desc = "Set custom treesitter highlights",
            })
            set_custom_highlights()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = false,
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]f"] = "@function.outer",
                            ["]k"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]F"] = "@function.outer",
                            ["]K"] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[f"] = "@function.outer",
                            ["[k"] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[F"] = "@function.outer",
                            ["[K"] = "@class.outer",
                        },
                    },
                },
            })
        end,
    },
}
