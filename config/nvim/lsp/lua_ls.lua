return {
    cmd = { 'lua-language-server' },

    filetypes = { 'lua' },

    root_markers= { { '.luarc.json', '.luarc.jsonc' }, '.git' },

    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim', 'hl' },
            },
            workspace = {
                library = { '/usr/share/hypr/stubs',
                vim.env.VIMRUNTIME,
            },
            checkThirdParty = false,
        },

        }
    }
}
