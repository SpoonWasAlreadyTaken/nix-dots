local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },

    completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged },
    },

    window = {
        completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection",
        }),

        documentation = cmp.config.window.bordered({
            border = "rounded",
        }),
    },

    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = function(fallback)
            fallback()
        end,
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),

        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        }, {
        { name = 'buffer' },
    }),

    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
        }),
    },
})

cmp.setup.filetype({ 'txt', 'text', }, {
    completion = {
        autocomplete = false,
    },
})

cmp.setup.cmdline(':', {
    completion = { autocomplete = false },
    mapping = cmp.mapping.preset.cmdline({
        ['<C-Space>'] = { c = cmp.mapping.complete(), },
    }),
    sources = cmp.config.sources({ { name = 'path' }, { name = 'cmdline' }, }),
})

cmp.setup.cmdline({'/', '?' }, {
    completion = { autocomplete = false },
    mapping = cmp.mapping.preset.cmdline({
        ['<C-Space>'] = { c = cmp.mapping.complete(), },
    }),
    sources = {{ name = 'buffer' }},
})












