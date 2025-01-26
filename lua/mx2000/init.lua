-- Load core configurations
require("mx2000.remap")
require("mx2000.set")
require("mx2000.lazy_init")

-- Theme setup
vim.cmd("colorscheme carbonfox")

-- Initialize autocommand groups
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local MX2000_GROUP = augroup("MX2000", {})

-- System clipboard synchronization
vim.api.nvim_create_autocmd({ "FocusGained" }, {
    group = MX2000_GROUP,
    pattern = { "*" },
    command = [[call setreg("@", getreg("+"))]],
    desc = "Sync system clipboard to Neovim on focus gain"
})

vim.api.nvim_create_autocmd({ "FocusLost" }, {
    group = MX2000_GROUP,
    pattern = { "*" },
    command = [[call setreg("+", getreg("@"))]],
    desc = "Sync Neovim clipboard to system on focus lost"
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = MX2000_GROUP,
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
    desc = "Highlight yanked text"
})

-- Return to last edit position
autocmd("BufReadPost", {
    group = MX2000_GROUP,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Return to last edit position when opening files"
})

-- Auto formatting
autocmd("BufWritePre", {
    group = MX2000_GROUP,
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
    desc = "Auto format on save"
})

-- Terminal settings
autocmd("TermOpen", {
    group = MX2000_GROUP,
    command = "startinsert",
    desc = "Enter insert mode when opening terminal"
})

-- LSP configurations
autocmd("LspAttach", {
    group = MX2000_GROUP,
    callback = function(e)
        local opts = { buffer = e.buf, desc = "", noremap = true, silent = true }
        local buf_map = function(mode, lhs, rhs, desc)
            opts.desc = desc
            vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- LSP actions
        buf_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        buf_map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        buf_map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        buf_map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
        buf_map("n", "gr", vim.lsp.buf.references, "Show references")
        buf_map("n", "K", vim.lsp.buf.hover, "Show hover documentation")
        buf_map("n", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")

        -- Workspace management
        buf_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        buf_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        buf_map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")

        -- Code actions and diagnostics
        buf_map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbol")
        buf_map("n", "<leader>vd", vim.diagnostic.open_float, "Open diagnostics float")
        buf_map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
        buf_map("n", "<leader>vrr", vim.lsp.buf.references, "Show references")
        buf_map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename symbol")
        buf_map("i", "<C-h>", vim.lsp.buf.signature_help, "Show signature help")

        -- Fix diagnostic navigation (was reversed)
        buf_map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        buf_map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        
        -- Format commands
        buf_map("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, "Format buffer")
    end,
    desc = "LSP configurations"
})
