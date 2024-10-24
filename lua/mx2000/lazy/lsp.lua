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
		"j-hui/fidget.nvim",
	},
	config = function()
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local util = require("mx2000.util") -- Your utility module
		require("fidget").setup({})
		local capabilities = cmp_lsp.default_capabilities()

		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["svelte"] = function()
				local svelte_caps = vim.lsp.protocol.make_client_capabilities()
				svelte_caps.workspace.didChangeWatchedFiles.dynamicRegistration = true
				svelte_caps.textDocument.completion = capabilities.textDocument.completion
				lspconfig["svelte"].setup({
					capabilities = svelte_caps,
				})
			end,
			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
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
			["basedpyright"] = function()
				lspconfig.pyright.setup({
					capabilities = capabilities,
					on_init = function(client)
						local file_path = client.config.root_dir
						client.config.settings.python.pythonPath = util.get_python_interpreter(file_path)
					end,
					root_dir = function(fname)
						return util.find_pyproject_toml(vim.fn.fnamemodify(fname, ":p:h")) or vim.fn.getcwd()
					end,
				})
			end,
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
			}),
		})

		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
	end,
}
