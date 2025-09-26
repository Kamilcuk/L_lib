local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
  mason_lspconfig.setup({
    automatic_enable = { exclude = { "shellcheck" } },
  })
end
