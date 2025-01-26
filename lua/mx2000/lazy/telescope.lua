return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local builtin = require('telescope.builtin')

        telescope.setup({
            defaults = {
                path_display = { "truncate" },
                prompt_prefix = " 🔍 ",
                selection_caret = " ",
                layout_config = {
                    horizontal = {
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                mappings = {
                    i = {
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-c>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                        ["<C-h>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<C-t>"] = actions.select_tab,
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,
                    },
                    n = {
                        ["<esc>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                        ["<C-h>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<C-t>"] = actions.select_tab,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,
                    },
                },
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                    ".cache",
                    "%.o",
                    "%.a",
                    "%.out",
                    "%.class",
                    "%.pdf",
                    "%.mkv",
                    "%.mp4",
                    "%.zip",
                },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob=!.git/",
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                }
            }
        })

        -- Load extensions
        telescope.load_extension('fzf')

        -- Keymaps
        local function find_git_root()
            local current_file = vim.api.nvim_buf_get_name(0)
            local current_dir
            local cwd = vim.fn.getcwd()
            if current_file == "" then
                current_dir = cwd
            else
                current_dir = vim.fn.fnamemodify(current_file, ":h")
            end
            local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
            if vim.v.shell_error ~= 0 then
                return cwd
            end
            return git_root
        end

        -- File pickers
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find files" })
        vim.keymap.set('n', '<C-p>', 
            function() 
                vim.fn.system('git rev-parse --is-inside-work-tree')
                if vim.v.shell_error == 0 then
                    builtin.git_files()
                else
                    builtin.find_files()
                end
            end, 
            { desc = "Find Git files" }
        )

        -- Search pickers
        vim.keymap.set('n', '<leader>ps', function()
            builtin.live_grep({
                cwd = find_git_root(),
            })
        end, { desc = "Live grep" })
        vim.keymap.set('n', '<leader>pw', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end, { desc = "Search current word" })
        vim.keymap.set('n', '<leader>pW', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end, { desc = "Search current WORD" })

        -- LSP pickers
        vim.keymap.set('n', '<leader>pd', builtin.diagnostics, { desc = "Search diagnostics" })
        vim.keymap.set('n', '<leader>pr', builtin.lsp_references, { desc = "Search references" })
        vim.keymap.set('n', '<leader>ps', builtin.lsp_document_symbols, { desc = "Search document symbols" })
        vim.keymap.set('n', '<leader>pws', builtin.lsp_workspace_symbols, { desc = "Search workspace symbols" })

        -- Other pickers
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = "Search help tags" })
        vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = "Command history" })
        vim.keymap.set('n', '<leader>/', builtin.search_history, { desc = "Search history" })
    end
}
