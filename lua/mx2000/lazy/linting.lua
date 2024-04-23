return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		local function find_project_root()
			local current_dir = vim.fn.getcwd()
			local previous_dir = ""

			while current_dir ~= previous_dir do
				if vim.fn.glob(current_dir .. "/.git") ~= "" then
					return current_dir
				end
				previous_dir = current_dir
				current_dir = vim.fn.fnamemodify(current_dir, ":h")
			end

			return nil
		end

		local path = require("lspconfig.util").path
		local function get_python_path(workspace)
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
			end

			-- Find and use virtualenv in workspace directory.
			local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
			if match ~= "" then
				local venv = vim.fn.trim(vim.fn.system("poetry env info -p"))
				if venv ~= "" then
					if vim.fn.has("macunix") == 1 then
						return path.join(venv, "bin", "python")
					else
						return path.join(venv, "Scripts", "python.exe")
					end
				end
			end

			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		lint.linters.pylint.cmd = get_python_path(find_project_root())
		lint.linters.pylint.args = { "-m", "pylint", "-f", "json" }

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
