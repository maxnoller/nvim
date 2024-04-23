

return {
    "neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile"},
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")


        require("fidget").setup({})
        local capabilities = cmp_lsp.default_capabilities()
        local svelte_caps = vim.lsp.protocol.make_client_capabilities()
        svelte_caps.workspace.didChangeWatchedFiles.dynamicRegistration = true
        svelte_caps.textDocument.completion = capabilities.textDocument.completion
        mason_lspconfig.setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities
                })
            end,
            ["svelte"] = function()
            -- configure svelte server
            lspconfig["svelte"].setup({
              capabilities = svelte_caps,
            })
            end,
            ["lua_ls"] = function()
            -- configure lua server (with special settings)
            lspconfig["lua_ls"].setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  -- make the language server recognize "vim" global
                  diagnostics = {
                    globals = { "vim" },
                  },
                  completion = {
                    callSnippet = "Replace",
                  },
                },
              },
            })
            end,
            ["pyright"] = function()
            local util = require("lspconfig/util")
            local path = util.path
            local function get_python_path(workspace)
              -- Use activated virtualenv.
              if vim.env.VIRTUAL_ENV then
                return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
              end

              -- Find and use virtualenv in workspace directory.
                local match = vim.fn.glob(path.join(workspace, 'poetry.lock'))
                  if match ~= '' then
                    local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
                    if venv ~= '' then
                        if vim.fn.has("macunix") == 1 then
                        return path.join(venv, 'bin', 'python')
                        else
                        return path.join(venv, 'Scripts', 'python.exe')
                        end
                    end
                  end

              -- Fallback to system Python.
              return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
            end

            lspconfig.pyright.setup {
                  capabilities = capabilities,
                  before_init = function(_,config)
                    config.settings.python.pythonPath = get_python_path(config.root_dir)
                  end
                }
            end,

        })
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = "luasnip" }
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
