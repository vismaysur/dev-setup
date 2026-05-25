-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
    -- tokyo night, storm: a cool colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function() 
            vim.cmd.colorscheme("tokyonight-storm")
        end,
    },

    -- mini.nvim: overpowered all-in-one plugin
    {
        "nvim-mini/mini.nvim",
        version = '*',
        config = function()
            require("mini.statusline").setup({ use_icons = true })
        end,
    },

    -- nvim-treesitter: provides queries, installs and manages parsers
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ':TSUpdate',
        config = function()
            local languages = { "lua", "markdown", "markdown_inline", "starlark", "c", "cpp" }

            require("nvim-treesitter.configs").setup({
                ensure_installed = languages,
                auto_install = true,
                highlight = {
                    enable = true
                },
                indent = {
                    enable = true
                },
            })

            vim.api.nvim_create_autocmd('FileType', {
                pattern = languages,
                callback = function()
                    -- syntax highlighting, provided by Neovim
                    vim.treesitter.start()
                end,
            })
        end,
    },

    -- mason: installs and manages LSP servers, DAP servers, linters, and formatters
    {
        "mason-org/mason.nvim",
        opts = {}
    },

    -- nvim-lspconfig: default LSP server configs
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            vim.lsp.config('*', {
                capabilities = capabilities
            })

            vim.filetype.add({
                filename = {
                  ["BUILD"]           = "bzl",
                  ["BUILD.bazel"]     = "bzl",
                  ["WORKSPACE"]       = "bzl",
                  ["WORKSPACE.bazel"] = "bzl",
                  ["MODULE.bazel"]    = "bzl",
                },
                extension = { bzl = "bzl" },
            })
        end,
        opts = {
          servers = {
            clangd = {
              mason = false,
            },
          },
        },
    },

    -- blink.cmp: auto-completion plugin 
    {
        'saghen/blink.cmp',
        dependencies = { 'rafamadriz/friendly-snippets' },
        version = '1.*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
          keymap = { preset = 'default' },

          appearance = {
            nerd_font_variant = 'mono'
          },

          completion = { documentation = { auto_show = false } },

          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
          },

          fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },

    -- telescope.nvim: highly extendable fuzzy finder
    {
        'nvim-telescope/telescope.nvim', version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function() 
            vim.keymap.set("n", "<space>fd", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<space>en", function()
                require('telescope.builtin').find_files {
                    cwd = vim.fn.stdpath("config")
                }
            end)
        end,
    }
})
