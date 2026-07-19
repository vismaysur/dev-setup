local set = vim.opt

set.tabstop = 2         -- Visual width of a tab
set.softtabstop = 2     -- Number of spaces inserted when hitting a tab
set.shiftwidth = 2      -- Number of spaces inserted for indentation
set.expandtab = true    -- Converts tabs to spaces

set.number = true
set.relativenumber = true

set.termguicolors = true

-- misc key bindings
vim.keymap.set('i', 'jk', '<Esc>', {noremap = true})

-- lua execution key bindings
vim.keymap.set('n', '<space><space>x', '<cmd>source %<Cr>', {noremap = true})   -- executes file
vim.keymap.set('n', '<space>x', '<cmd>.lua<Cr>', {noremap = true})              -- executes current line
vim.keymap.set('v', '<space>x', ':lua<Cr>', {noremap = true})                   -- executes selected code

-- lazy.nvim
require("config.lazy")

-- enable LSP servers
vim.lsp.enable({
    "lua_ls",
    "mlir_lsp_server",
    "tblgen_lsp_server",
    "mlir_pdll_lsp_server",
    "clangd",
    "pyright",
})

-- diagnostic UI
vim.diagnostic.config({
    virtual_text = true
})

vim.env.PAT = vim.env.HOME .. '/.local/bin:' .. vim.env.PATH
