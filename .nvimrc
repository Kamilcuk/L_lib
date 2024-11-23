" :LspStop
" autocmd BufEnter,BufRead *.sh :LspStop
lua <<EOF
require "nvim-treesitter.configs".setup {
  highlight = {
    enable = false, -- false will disable the whole extension
    disable = { "css", "clojure" }, -- list of language that will be disabled
  },
}
EOF
