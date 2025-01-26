return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "j-hui/fidget.nvim",
        "folke/neodev.nvim", -- better lua development
    },
    config = function()
        -- Setup neovim lua configuration
        require("neodev").setup()
        
        -- Setup fidget to show LSP progress
        require("fidget").setup({
            notification = {
                window = {
                    winblend = 0
                }
            }
        })
        
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local util = require("mx2000.util")
        local luasnip = require("luasnip")
        
        -- Load friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

        local mason_lspconfig = require("mason-lspconfig").setup({
            ensure_installed = {
                "ts_ls",
                "html",
                "cssls",
                "tailwindcss",
                "svelte",
                "lua_ls",
                "basedpyright",
                "ruff",
            },
            handlers = {
                function(server_name)
                    local capabilities = vim.tbl_deep_extend(
                        "force",
                        {},
                        vim.lsp.protocol.make_client_capabilities(),
                        cmp_lsp.default_capabilities(),
                        { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
                    )

                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = function(client, bufnr)
                            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
                        end
                    })
                end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = { version = "Lua 5.1" },
								diagnostics = {
									globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
				["ruff"] = function()
					require("lspconfig").ruff.setup({
						-- cmd = { "ruff", "server", "--preview" },
						cmd_env = { RUFF_TRACE = "messages" },
						init_option = {
							settings = {
								loglevel = "error",
							},
						},
					})
				end,
				["basedpyright"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.basedpyright.setup({
						capabilities = capabilities,
						on_attach = function(client)
							local file_path = client.config.root_dir
							lspconfig.basedpyright.commands.PyrightSetPythonPath[1](
								util.get_python_interpreter(file_path)
							)
						end,
					})
				end,
			},
		})

        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer", keyword_length = 3 },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snippet]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                    })[entry.source.name]
                    return vim_item
                end
            },
            experimental = {
                ghost_text = true,
            },
        })

        -- Set configuration for diagnostics
        vim.diagnostic.config({
            virtual_text = {
                prefix = '●',
                source = "if_many",
            },
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Show line diagnostics automatically in hover window
        vim.o.updatetime = 250
        vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

        -- Add rounded borders to LspInfo window
        require('lspconfig.ui.windows').default_options.border = 'rounded'
	end,
}
