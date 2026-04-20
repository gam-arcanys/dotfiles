return {
    {
        "mfussenegger/nvim-lint",
        dependencies = {"mason.nvim"},
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                rust = {"clippy"},
                cpp = {"cppcheck"},
                javascript = {"eslint_d"},
                javascriptreact = {"eslint_d"},
                typescript = {"eslint_d"},
                typescriptreact = {"eslint_d"},
                lua = {"luacheck"},
                ruby = {"rubocop"},
                python = {"ruff"},
                css = {"stylelint"},
                scss = {"stylelint"}
            }

            local group = vim.api.nvim_create_augroup("lint", {clear = true})

            vim.api.nvim_create_autocmd(
                {"BufWritePost", "BufEnter", "BufLeave"},
                {group = group, callback = function()
                    lint.try_lint()
                end})
        end
    }, {
        "rshkarin/mason-nvim-lint",
        dependencies = {"mason.nvim", "mfussenegger/nvim-lint"},
        config = function()
            require("mason-nvim-lint").setup({
                automatic_installation = true,
                quiet_mode = true,
                ignore_install = {"luacheck"},
            })
        end
    }
}
