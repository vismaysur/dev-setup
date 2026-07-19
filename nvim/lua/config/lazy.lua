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
            local languages = { "lua", "markdown", "markdown_inline", "starlark", "c", "cpp", "python" }

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

            vim.api.nvim_create_autocmd('LspAttach', {
              callback = function(args)
                local opts = { buffer = args.buf, silent = true }

                vim.keymap.set('n', 'gd', function() 
                  vim.lsp.buf.definition()
                end, opts)

                vim.keymap.set('i', '<C-y>', function() 
                  vim.lsp.buf.signature_help({ border = 'rounded', max_width = 80 })
                end, opts)

                vim.keymap.set('n', 'K', function() 
                  vim.lsp.buf.hover({ border = 'rounded', max_width = 80 })
                end, opts)
              end,
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
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function() 
            local builtin = require('telescope.builtin')

            vim.keymap.set("n", "<space>fd", function() 
                builtin.find_files( 
                    require('telescope.themes').get_ivy({})
                )
            end)

            vim.keymap.set("n", "<space>en", function()
                builtin.find_files(
                    require('telescope.themes').get_ivy({
                        cwd = vim.fn.stdpath("config")
                    })
                )
            end)

            vim.keymap.set("n", "<space>fg", function()
                builtin.live_grep(
                    require('telescope.themes').get_ivy({})
                )
           end)
        end,
    },

    -- conform.nvim: formatter
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    tablegen = { "clang_format" },
                },
                format_on_save = {
                    timeout_ms = 1000,
                    lsp_fallback = true,
                },
            })
        end,
    }
})
