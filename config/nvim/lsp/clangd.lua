return {
    cmd = { 'clangd', '--background-index' },

    filetypes = { 'c', 'cpp' },

    root_markers = { '.clangd', 'compile_commands.json', 'clang-tidy', 'clang-format', '.git' },

}
