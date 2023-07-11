local vim_opts = {
    encoding = "utf-8",
    title = false,
    ruler = true,  -- Show the cursor position
    number = true, -- 行番号の表示
    list = true,   -- Show invisible characters
    listchars = {
        tab = "» ",
        trail = "·",
        nbsp = "·",
        eol = "↲",
    },
    cursorline = true,
    expandtab = true,               -- タブを空白に置き換える
    tabstop = 2,                    -- タブ幅
    softtabstop = 2,                -- バックスペースなどで削除する空白の数
    shiftwidth = 2,                 -- インデント幅
    autoindent = true,              -- 改行時に入力された行のインデントを継続する
    smartindent = true,             -- 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
    whichwrap = "b,s,h,l,<,>,[,]",  -- カーソルを行頭、行末で止まらないようにする
    backspace = "indent,eol,start", -- バックスペースを有効にする
    colorcolumn = "100",
    synmaxcol = 200,                -- シンタックスハイライトは一行につき200文字までとする
    backup = false,                 -- ファイル保存時にバックアップファイルを作らない
    swapfile = false,               -- ファイル編集中にスワップファイルを作らない
    wildmenu = true,                -- コマンドラインモードで<Tab>キーによるファイル名補完を有効にする
    history = 100,                  -- keep command line history
    hlsearch = true,                -- 検索文字列をハイライトする
    incsearch = true,               -- do incremental searching
    ignorecase = true,              -- 大文字と小文字を区別しない
    smartcase = true,               -- 大文字と小文字が混在している場合は大文字と小文字を区別する
    laststatus = 0,                 -- display status line
    scrolloff = 4,
    sidescrolloff = 8,
    pumheight = 20,
    signcolumn = "yes",
    showmode = false,
    clipboard = "unnamed",
    mouse = "a",
    visualbell = true,
    errorbells = false,
    grepprg = "rg --vimgrep"
}

for k, v in pairs(vim_opts) do
    vim.opt[k] = v
end

local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", ";", ":", keymap_opts)
vim.api.nvim_set_keymap("n", ":", ";", keymap_opts)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy_opts = {
    ui = {
        border = "rounded",
        icons = {
            ft = "",
            lazy = "󰂠 ",
            loaded = "",
            not_loaded = "",
        },
    },
}
require("lazy").setup({
    -- TreeSitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        opts = {
            -- A list of parser names, or "all" (the five listed parsers should always be installed)
            ensure_installed = { "go", "javascript", "typescript", "tsx", "lua" },
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
        -- @param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    -- LSP
    {
        "williamboman/mason.nvim",
        -- cmd = "Mason",
        build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "󰄳 ",
                    package_pending = " ",
                    package_uninstalled = " ",
                },
            },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "gopls" },
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            require("mason-lspconfig").setup_handlers {
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({})
                end,
                -- Next, you can provide a dedicated handler for specific servers.
                -- For example, a handler override for the `rust_analyzer`:
                -- ["rust_analyzer"] = function()
                --   require("rust-tools").setup({})
                -- end
            }
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim"
        },
        config = function(_, opts)
            local signs = { Error = " ", Warn = " ", Hint = " ", Information = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover,
                { border = "rounded", silent = true, blend = 0 }
            )
            vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

            local function keymapping(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = bufnr }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<space>f', function()
                    vim.lsp.buf.format { async = true }
                end, opts)
            end

            local function formatting(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                end
            end

            local function on_attach(client, bufnr)
                keymapping(client, bufnr)
                formatting(client, bufnr)
            end

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local bufnr = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    on_attach(client, bufnr)
                end,
            })
        end
    },
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                -- Opt to list sources here, when available in mason.
                "goimports"
            },
            automatic_installation = false,
            handlers = {},
        }
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        -- opts = function()
        --   local nls = require("null-ls")
        --   return {
        --     sources = {
        --       -- Anything not supported by mason.
        --       nls.builtins.formatting.goimports,
        --     },
        --   }
        -- end,
        config = true
    },
    {
        "j-hui/fidget.nvim",
        opts = {
            text = {
                spinner = "dots", -- animation shown when tasks are ongoing
                done = " ",    -- character shown when all tasks are complete
            },
            window = {
                blend = 0, -- &winblend for the window
            },
        }
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
        },
        opts = function(_, opts)
            local cmp = require("cmp")
            local lspkind = require('lspkind')
            return {
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        local kind = lspkind.cmp_format({
                            mode = "symbol_text", maxwidth = 50
                        })(entry, vim_item)
                        local strings = vim.split(kind.kind, "%s", { trimempty = true })
                        kind.kind = " " .. (strings[1] or "") .. " "
                        kind.menu = "    (" .. (strings[2] or "") .. ")"
                        return kind
                    end
                },
                completion = {
                    keyword_length = 2,
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'luasnip' },
                }),
            }
        end,
        config = function(_, opts)
            local cmp = require 'cmp'
            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
            cmp.setup(opts)
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = true
    },
    -- {
    --     'akinsho/bufferline.nvim',
    --     version = "*",
    --     dependencies = 'nvim-tree/nvim-web-devicons',
    --     config = function(_, opts)
    --         vim.opt.termguicolors = true
    --         require("bufferline").setup(opts)
    --     end,
    -- },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = true
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        init = function()
            vim.g.neo_tree_remove_legacy_commands = true
        end,
        opts = {
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/753#issuecomment-1440085270
            use_popups_for_input = false,
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_by_pattern = {
                        '.git'
                    }
                }
            },
            default_component_configs = {
                icon = {
                    folder_empty = "󰜌",
                    folder_empty_open = "󰜌",
                },
                git_status = {
                    symbols = {
                        renamed  = "󰁕",
                        unstaged = "󰄱",
                    },
                },
            },
            document_symbols = {
                kinds = {
                    File = { icon = "󰈙", hl = "Tag" },
                    Namespace = { icon = "󰌗", hl = "Include" },
                    Package = { icon = "󰏖", hl = "Label" },
                    Class = { icon = "󰌗", hl = "Include" },
                    Property = { icon = "󰆧", hl = "@property" },
                    Enum = { icon = "󰒻", hl = "@number" },
                    Function = { icon = "󰊕", hl = "Function" },
                    String = { icon = "󰀬", hl = "String" },
                    Number = { icon = "󰎠", hl = "Number" },
                    Array = { icon = "󰅪", hl = "Type" },
                    Object = { icon = "󰅩", hl = "Type" },
                    Key = { icon = "󰌋", hl = "" },
                    Struct = { icon = "󰌗", hl = "Type" },
                    Operator = { icon = "󰆕", hl = "Operator" },
                    TypeParameter = { icon = "󰊄", hl = "Type" },
                    StaticMethod = { icon = '󰠄 ', hl = 'Function' },
                }
            },
            -- Add this section only if you've configured source selector.
            source_selector = {
                sources = {
                    { source = "filesystem", display_name = " 󰉓 Files " },
                    { source = "git_status", display_name = " 󰊢 Git " },
                },
            },
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            local keymap_opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>Neotree reveal<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>tw", "<cmd>Neotree close<cr>", keymap_opts)
        end,
    },
    {
        "folke/trouble.nvim",
        opts = {
            use_diagnostic_signs = false
        },
        config = function(_, opts)
            require("trouble").setup(opts)
            local keymap_opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>xl", "<cmd>Trouble loclist<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>xq", "<cmd>Trouble quickfix<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "gR", "<cmd>Trouble lsp_references<cr>", keymap_opts)
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
        },
        opts = {
            defaults = {
                prompt_prefix = "   ",
                selection_caret = " ",
                file_ignore_patterns = { "node_modules" },
                winblend = 0,
            },
            pickers = {
                find_files = {
                    find_command = { 'rg', '--files', '--hidden', '--glob', '!.git' }
                },
                buffers = {
                    sort_lastused = true
                }
            }
        },
        config = function(_, opts)
            local telescope = require('telescope')
            telescope.setup(opts)
            telescope.load_extension('fzf')
            local keymap_opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', keymap_opts)
            vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', keymap_opts)
            vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', keymap_opts)
            vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', keymap_opts)
        end
    },
    -- {
    --     "petertriho/nvim-scrollbar",
    --     dependencies = {
    --         "kevinhwang91/nvim-hlslens",
    --         "lewis6991/gitsigns.nvim"
    --     },
    --     opts = {
    --         hide_if_all_visible = true,
    --         handle = {
    --             text = " ",
    --             blend = 60,
    --         },
    --         excluded_filetypes = {
    --             "prompt",
    --             "TelescopePrompt",
    --             "neo-tree", "neo-tree-popup"
    --         }
    --     },
    --     config = function(_, opts)
    --         require("scrollbar").setup(opts)
    --         require("scrollbar.handlers.gitsigns").setup()
    --     end,
    -- },
    -- {
    --     "kevinhwang91/nvim-hlslens",
    --     config = function(_, opts)
    --         -- require('hlslens').setup() is not required
    --         require("scrollbar.handlers.search").setup({
    --             -- hlslens config overrides
    --         })

    --         local keymap_opts = { noremap = true, silent = true }
    --         vim.api.nvim_set_keymap('n', 'n',
    --             [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    --             keymap_opts)
    --         vim.api.nvim_set_keymap('n', 'N',
    --             [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    --             keymap_opts)
    --         vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], keymap_opts)
    --         vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], keymap_opts)
    --         vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], keymap_opts)
    --         vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], keymap_opts)
    --         vim.api.nvim_set_keymap('n', '<Leader>l', '<Cmd>noh<CR>', keymap_opts)
    --     end
    -- },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
        },
        config = function(_, opts)
            require('gitsigns').setup(opts)
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts =
        {
            show_trailing_blankline_indent = false,
            show_first_indent_level = true,
            show_current_context = true,
            show_current_context_start = false,
        }
    },
    {
        "folke/which-key.nvim",
        opts = {
            window = {
                border = "single",
            }
        }
    },
    { "echasnovski/mini.pairs",    config = true },
    { "echasnovski/mini.surround", config = true },
    { "echasnovski/mini.comment",  config = true },
    { "folke/todo-comments.nvim",  config = true },
    {
        "EdenEast/nightfox.nvim",
        opts = {
            groups = {
                all = {
                    -- { fg = "fg1", bg = "bg1" } by default
                    FloatBorder = { fg = "fg0", bg = "bg0" }
                }
            }
        },
        init = function()
            vim.cmd.colorscheme("nordfox")
        end,
    },
    {
        "xiyaowong/transparent.nvim",
        build = ":TransparentEnable",
        opts = { extra_groups = { "NeotreeNormal", "NeoTreeNormalNc" } },
        config = function(_, opts)
            require("transparent").setup(opts)
            -- vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, { "ExtraGroup" })
        end,
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
    },
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
    },

}, lazy_opts)
