package.path = package.path .. ';' .. vim.fn.expand('~/.config/?.lua')
local colors = require('theme.colors')

vim.o.laststatus = 3


function Mode()
    local m = vim.fn.mode()
    local modes = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        [""] = "V-BLOCK",
        c = "COMMAND",
        R = "REPLACE",
        t = "TERMINAL",
    }
    return modes[m] or m
end

local function setup_custom_highlights()
    vim.api.nvim_set_hl(0, "TextHL", { fg="#040405",bg=colors.primary,bold=true })
    vim.api.nvim_set_hl(0, "SymbolHL", { fg=colors.primary,bg="#040405",bold=true })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg="#ff7c36",bg="#040405",bold=true })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#26324d",bg = "#040405",italic = true })
    vim.api.nvim_set_hl(0, "Pmenu", { fg="#e2e2e2", bg="#040405" })
    vim.api.nvim_set_hl(0, "PmenuSel", { fg="#e2e2e2", bg= colors.primaryVeryDark })
    vim.api.nvim_set_hl(0, "G1", { fg = "#040405", bg = colors.primaryVeryDark })
    vim.api.nvim_set_hl(0, "G2", { fg = colors.primaryVeryDark, bg = colors.primaryDarker })
    vim.api.nvim_set_hl(0, "G3", { fg = colors.primaryDarker, bg = colors.primaryDark })
    vim.api.nvim_set_hl(0, "G0", { fg = colors.primaryDark, bg = colors.primary })
    vim.api.nvim_set_hl(0, "GR1", { fg = colors.primaryDark, bg = colors.primaryDarker })
    vim.api.nvim_set_hl(0, "GR2", { fg = colors.primaryDarker, bg = colors.primaryVeryDark })
    vim.api.nvim_set_hl(0, "GR3", { fg = colors.primaryVeryDark, bg = "#040405" })
    vim.api.nvim_set_hl(0, "GR0", { fg = colors.primary, bg = colors.primaryDark })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_custom_highlights,
})
setup_custom_highlights()


local statusline = {
    '%#GR3#',' ', '%#GR2#', ' ', '%#GR1#', ' ', '%#G3#', ' ', '%#TextHL#',' %{v:lua.Mode()}',
    '%#GR0#', '','%#GR1#','', '%#GR2#','', '%#GR3#','',

    '%#G1#','', '%#G2#','', '%#G3#','','%#G0#', '',
    '%#TextHL#',' %t', -- file
    '%r', -- if is read only
    '%m ', -- if modified
    '%#GR0#', '','%#GR1#','', '%#GR2#','', '%#GR3#','',

    '%#G1#','', '%#G2#','', '%#G3#','','%#G0#', '',
    '%#TextHL#',' %{&filetype} ', --file type
    '%#GR0#', '','%#GR1#','', '%#GR2#','', '%#GR3#','',


    '%=', -- splits left and right

    '%#GR3#','','%#GR2#','', '%#GR1#','','%#GR0#','',
    '%#TextHL#',' %l', -- line number
    ':',
    '%c ', -- column number
    '%#G0#','', '%#G3#','','%#G2#','','%#G1#','',

    '%#GR3#','','%#GR2#','', '%#GR1#','','%#GR0#','',
    '%#TextHL#',' %2p%% ', -- view percentige
    '%#G0#','', '%#G3#','','%#G2#','','%#G1#','',

    '%#GR3#','','%#GR2#','', '%#GR1#','','%#GR0#','',
    '%#TextHL#',' %{winnr()} ', --  window number
    '%#GR0#', ' ','%#GR1#',' ', '%#GR2#', ' ', '%#GR3#', ' ',
}

vim.o.statusline = table.concat(statusline, '')


-- 
-- 
-- 
