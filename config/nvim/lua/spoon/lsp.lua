local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=never",
    },
    capabilities = capabilities,
})


vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('ols')
vim.lsp.enable('nil')


vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client_id = args.data and args.data.client_id
        if not client_id then return end

        local client = vim.lsp.get_client_by_id(client_id)
        if not client then return end

        if client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

    end,
})

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰻖 ",
            [vim.diagnostic.severity.WARN]  = "󰀪 ",
            [vim.diagnostic.severity.HINT]  = "󱧢 ",
            [vim.diagnostic.severity.INFO]  = "󰧑 ",
        },
    },

    virtual_text = true,
    float = { border = "rounded", },
})


