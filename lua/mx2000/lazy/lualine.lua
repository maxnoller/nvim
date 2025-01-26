return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status")

        -- Custom component for mode with icons
        local mode_map = {
            ['NORMAL'] = ' ',
            ['INSERT'] = ' ',
            ['VISUAL'] = ' ',
            ['V-LINE'] = ' ',
            ['V-BLOCK'] = ' ',
            ['REPLACE'] = ' ',
            ['COMMAND'] = ' ',
        }

        local mode = {
            function()
                local m = vim.api.nvim_get_mode().mode
                local current_mode = mode_map[vim.fn.mode()] or ''
                return current_mode .. (mode_map[m] or m)
            end,
        }

        -- Diagnostics component
        local diagnostics = {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            colored = true,
            update_in_insert = false,
            always_visible = false,
        }

        lualine.setup({
            options = {
                theme = 'auto',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
                globalstatus = true,
                disabled_filetypes = {
                    statusline = { "dashboard", "alpha" },
                    winbar = {},
                },
            },
            sections = {
                lualine_a = { mode },
                lualine_b = {
                    { 'branch', icon = '' },
                    { 'diff',
                        symbols = {
                            added = ' ',
                            modified = ' ',
                            removed = ' '
                        }
                    },
                },
                lualine_c = {
                    { 'filename', path = 1 }
                },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    { "encoding" },
                    { "fileformat" },
                    { "filetype", icon_only = true },
                },
                lualine_y = { diagnostics },
                lualine_z = {
                    { 'progress', separator = ' ',                  padding = { left = 1, right = 0 } },
                    { 'location', padding = { left = 0, right = 1 } },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
            },
            extensions = { 'fugitive', 'nvim-tree', 'toggleterm' }
        })
    end,
}
