local function has_pkg_dep(root, dep)
    local f = io.open(root .. "/package.json", "r")
    if not f then return false end
    local content = f:read("*a")
    f:close()
    return content:find('"' .. dep .. '"') ~= nil
end

local function find_pkg_dep(file_path, dep)
    local dir = vim.fn.fnamemodify(file_path, ":h")
    for _ = 1, 10 do
        if has_pkg_dep(dir, dep) then return true end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then break end
        dir = parent
    end
    return false
end

local function is_js_test_file(file_path)
    return file_path:match("%.[ts][pe][se][tc]%.[jt]sx?$") ~= nil
        or file_path:match("/__tests__/") ~= nil
end

local function toggle_test_file()
    local current = vim.fn.expand("%:p")
    local ext = current:match("%.([jt]sx?)$")

    -- JS/TS: foo.test.ts <-> foo.ts, foo.spec.ts <-> foo.ts
    if ext then
        local base = current:match("(.-)%.test%." .. ext .. "$")
            or current:match("(.-)%.spec%." .. ext .. "$")
        if base then
            local src = base .. "." .. ext
            if vim.fn.filereadable(src) == 1 then
                return vim.cmd("edit " .. vim.fn.fnameescape(src))
            end
            return vim.notify("Source not found: " .. vim.fn.fnamemodify(src, ":~:."), vim.log.levels.WARN)
        end
        -- Source -> test: try .test first, then .spec
        for _, suffix in ipairs({ "test", "spec" }) do
            local test = current:gsub("%." .. ext .. "$", "." .. suffix .. "." .. ext)
            if vim.fn.filereadable(test) == 1 then
                return vim.cmd("edit " .. vim.fn.fnameescape(test))
            end
        end
        return vim.notify("No test file found", vim.log.levels.INFO)
    end

    -- Python: test_foo.py <-> foo.py
    if current:match("%.py$") then
        local dir, base = current:match("(.*)/test_([^/]+)%.py$")
        if dir and base then
            local src = dir .. "/" .. base .. ".py"
            if vim.fn.filereadable(src) == 1 then
                return vim.cmd("edit " .. vim.fn.fnameescape(src))
            end
            return vim.notify("Source not found: " .. vim.fn.fnamemodify(src, ":~:."), vim.log.levels.WARN)
        end
        local d, b = current:match("(.*)/([^/]+)%.py$")
        if d and b then
            local test = d .. "/test_" .. b .. ".py"
            if vim.fn.filereadable(test) == 1 then
                return vim.cmd("edit " .. vim.fn.fnameescape(test))
            end
            return vim.notify("No test file found", vim.log.levels.INFO)
        end
    end

    vim.notify("No test/source counterpart detected", vim.log.levels.INFO)
end

return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest",
            "nvim-neotest/neotest-python",
            "rouge8/neotest-rust",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-jest")({
                        jestCommand = "npx jest",
                        env = { CI = "true" },
                        is_test_file = function(file_path)
                            return is_js_test_file(file_path)
                                and find_pkg_dep(file_path, "jest")
                                and not find_pkg_dep(file_path, "vitest")
                        end,
                    }),
                    require("neotest-vitest")({
                        is_test_file = function(file_path)
                            return is_js_test_file(file_path)
                                and find_pkg_dep(file_path, "vitest")
                        end,
                    }),
                    require("neotest-python")({
                        runner = "pytest",
                        python = function()
                            local cwd = vim.fn.getcwd()
                            for _, dir in ipairs({ ".venv", "venv", ".env" }) do
                                local py = cwd .. "/" .. dir .. "/bin/python"
                                if vim.fn.executable(py) == 1 then return py end
                            end
                            return "python3"
                        end,
                        args = { "--tb=short" },
                    }),
                    -- Requires: cargo install cargo-nextest
                    require("neotest-rust")({
                        args = { "--no-capture" },
                    }),
                },
                output = { open_on_run = false },
                summary = { follow = true, expand_errors = true },
                status = { virtual_text = true, signs = true },
                discovery = {
                    filter_dir = function(name)
                        local skip = { node_modules = true, [".git"] = true, dist = true, build = true, [".next"] = true, target = true }
                        return not skip[name]
                    end,
                },
            })
        end,
        init = function()
            local map = function(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
            end
            local nt = function() return require("neotest") end

            map("<leader>tn", function() nt().run.run() end, "Run nearest test")
            map("<leader>tf", function() nt().run.run(vim.fn.expand("%")) end, "Run test file")
            map("<leader>ts", function() nt().run.run({ suite = true }) end, "Run test suite")
            map("<leader>tl", function() nt().run.run_last() end, "Re-run last test")
            map("<leader>to", function() nt().output_panel.toggle() end, "Toggle output panel")
            map("<leader>tO", function() nt().output.open({ enter = true }) end, "Open test output popup")
            map("<leader>tS", function() nt().summary.toggle() end, "Toggle summary")
            map("<leader>tx", function() nt().run.stop() end, "Stop test run")
            map("<leader>t]", function() nt().jump.next({ status = "failed" }) end, "Next failed test")
            map("<leader>t[", function() nt().jump.prev({ status = "failed" }) end, "Prev failed test")
            map("<leader>ta", toggle_test_file, "Toggle source/test file")
        end,
    },
}
