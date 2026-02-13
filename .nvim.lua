
if false then
	local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if ok then
		mason_lspconfig.setup({
			automatic_enable = { exclude = { "shellcheck" } },
		})
	end

	vim.cmd.LspStop()
	vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
		pattern = { "*.sh" },
		callback = function()
			pcall(vim.cmd.LspStop)
		end,
	})

	require("nvim-treesitter.configs").setup({
		highlight = {
			enable = false, -- false will disable the whole extension
			disable = { "sh", "bash" }, -- list of language that will be disabled
		},
	})
end
