return {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            local ls = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()
            
            -- Extend filetypes
            ls.filetype_extend("javascript", { "jsdoc" })
            ls.filetype_extend("typescript", { "javascript" })
            ls.filetype_extend("javascriptreact", { "javascript" })
            ls.filetype_extend("typescriptreact", { "typescript" })
            ls.filetype_extend("svelte", { "javascript", "typescript", "html" })

            -- Settings
            ls.config.set_config({
                history = true, -- keep track of snippet history
                updateevents = "TextChanged,TextChangedI", -- update changes as you type
                enable_autosnippets = true,
                ext_opts = {
                    [require("luasnip.util.types").choiceNode] = {
                        active = {
                            virt_text = { { "●", "GruvboxOrange" } },
                        },
                    },
                },
            })

            -- Key Mappings
            vim.keymap.set({"i"}, "<C-s>e", function() 
                if ls.expandable() then
                    ls.expand()
                end
            end, {silent = true, desc = "Expand snippet"})

            vim.keymap.set({"i", "s"}, "<C-s>;", function() 
                if ls.jumpable(1) then
                    ls.jump(1)
                end
            end, {silent = true, desc = "Jump forward in snippet"})

            vim.keymap.set({"i", "s"}, "<C-s>,", function() 
                if ls.jumpable(-1) then
                    ls.jump(-1)
                end
            end, {silent = true, desc = "Jump backward in snippet"})

            vim.keymap.set({"i", "s"}, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, {silent = true, desc = "Change snippet choice"})

            -- Unlink snippet on mode change
            vim.api.nvim_create_autocmd("ModeChanged", {
                pattern = {'s:n', 'i:*'},
                callback = function()
                    if ls.in_snippet() then
                        ls.unlink_current()
                    end
                end
            })
        end,
    }
}
