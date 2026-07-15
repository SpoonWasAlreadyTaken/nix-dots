local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },

    completion = {
        autocomplete = false,
    },

    window = {
        completion = cmp.config.window.bordered({
        border = "rounded",
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
        }),
        documentation = cmp.config.window.bordered({
        border = "rounded",
        }),
    },

    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = function(fallback)
            fallback()
        end,

        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
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

cmp.setup.filetype({ 'lua', 'c', 'cpp', 'cs', 'hpp', 'h' }, {
    completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged },
    },
})


