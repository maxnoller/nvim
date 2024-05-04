local M = {}

local function path_join(...)
    return table.concat({ ... }, '/')
end

local function interpreter_os(base_path)
    if vim.fn.has("win32") then
        return path_join(base_path, "Scripts", "python.exe")
    else
        return path_join(base_path, "bin", "python")
    end
end

local function find_workspace()
    local current_dir = vim.fn.getcwd()
    local git_dir = current_dir
    while git_dir ~= '/' do
        if vim.fn.isdirectory(git_dir .. "/.git") == 1 then
            return git_dir
        end
        git_dir = vim.fn.fnamemodify(git_dir, ':h')
    end
    return nil
end

function M.get_python_interpreter()
    if vim.env.VIRTUAL_ENV then
        return interpreter_os(vim.env.VIRTUAL_ENV)
    end

    local workspace = find_workspace()

    -- Find and use virtualenv in workspace directory.
    local match = vim.fn.glob(path_join(workspace, 'poetry.lock'))
    if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
        if venv ~= '' then
            return interpreter_os(venv)
        end
    end

    -- Fallback to system Python.
    return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

return M
