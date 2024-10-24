return {
	{
		"folke/trouble.nvim",
		opts = {
			warn_no_results = false,
			open_no_results = true,
		},
		keys = {
			{ "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "yo" },
		},
	},
}
