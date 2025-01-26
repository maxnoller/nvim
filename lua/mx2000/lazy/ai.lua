return {
    {
        "github/copilot.vim",
        event = "InsertEnter",
        config = function()
            -- Disable copilot for certain filetypes
            vim.g.copilot_filetypes = {
                ["*"] = true,
                ["markdown"] = true,
                ["help"] = false,
            }
            
            -- Customize tab behavior
            vim.g.copilot_no_tab_map = true
            vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept copilot suggestion"
            })
            
            -- Additional keymaps for suggestion navigation
            vim.keymap.set("i", "<C-]>", '<Plug>(copilot-next)', { desc = "Next copilot suggestion" })
            vim.keymap.set("i", "<C-[>", '<Plug>(copilot-previous)', { desc = "Previous copilot suggestion" })
            vim.keymap.set("i", "<C-\\>", '<Plug>(copilot-dismiss)', { desc = "Dismiss copilot suggestion" })
            
            -- Enable copilot by default
            vim.g.copilot_assume_mapped = true
        end,
    }
}
