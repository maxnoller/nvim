local M = {}

local function path_join(...)
	return table.concat({ ... }, "/")
end

local function interpreter_os(base_path)
	if vim.fn.has("win32") == 1 then
		return path_join(base_path, "Scripts", "python.exe")
	else
		return path_join(base_path, "bin", "python")
	end
end

function M.find_pyproject_toml(start_path)
	local current_dir = start_path
	while current_dir ~= "/" do
		local pyproject_path = path_join(current_dir, "pyproject.toml")
		if vim.fn.filereadable(pyproject_path) == 1 then
			return current_dir
		end
		current_dir = vim.fn.fnamemodify(current_dir, ":h")
	end
	return nil
end

function M.get_python_interpreter(file_path)
	if vim.env.VIRTUAL_ENV then
		return interpreter_os(vim.env.VIRTUAL_ENV)
	end

	local project_root = M.find_pyproject_toml(vim.fn.fnamemodify(file_path, ":p:h"))
	if project_root then
		local poetry_lock = path_join(project_root, "poetry.lock")
		if vim.fn.filereadable(poetry_lock) == 1 then
			local venv = vim.fn.trim(vim.fn.system("cd " .. project_root .. " && poetry env info -p"))
			if venv ~= "" then
				return interpreter_os(venv)
			end
		end
	end

	-- Fallback to system Python
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return M
