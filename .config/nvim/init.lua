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
    laststatus = 2,                 -- display status line
    clipboard = "unnamed",
    mouse = "a",
    visualbell = true,
    errorbells = false,
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
        config = true,
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
        config = true
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
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
        opts = {
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_by_pattern = {
                        '.git'
                    }
                }
            }
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            local keymap_opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>Neotree reveal<cr>", keymap_opts)
            vim.api.nvim_set_keymap("n", "<leader>tw", "<cmd>Neotree close<cr>", keymap_opts)
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        end,
    },
    {
        "folke/trouble.nvim",
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
            pickers = {
                -- find_files = {
                --   find_command = {'rg', '--files', '--hidden', '--glob', '!.git'}
                -- },
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
    { "folke/which-key.nvim",      config = true },
    { "echasnovski/mini.pairs",    config = true },
    { "echasnovski/mini.surround", config = true },
    { "echasnovski/mini.comment",  config = true },
    { "folke/todo-comments.nvim",  config = true },
    {
        "EdenEast/nightfox.nvim",
        config = function(_, opts)
            vim.cmd.colorscheme("nordfox")
        end
    }
})
