return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer", "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help", "hrsh7th/cmp-path"
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = {menu = 50, abbr = 50},
                        ellipsis_char = "...",
                        show_labelDetails = true,
                        before = function(entry, vim_item)
                            return vim_item
                        end
                    })
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {"i", "s"})
                }),
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset, cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality, cmp.config.compare.kind,
                        cmp.config.compare.sort_text, cmp.config.compare.length,
                        cmp.config.compare.order
                    }
                },
                sources = {
                    {name = "nvim_lsp"}, {name = "luasnip"},
                    {name = "nvim_lsp_signature_help"}, {name = "path"}, {
                        name = "lazydev",
                        group_index = 0 -- set group index to 0 to skip loading LuaLS completions
                    }
                }
            })

            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {{name = "buffer"}}
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({{name = "path"}},
                                             {{name = "cmdline"}})
            })

            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({}))
        end
    }
}
