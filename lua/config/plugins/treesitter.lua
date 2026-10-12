return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  main = "nvim-treesitter",
  config = function()
    local ts = require("nvim-treesitter")
    local parsers = {
      "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript",
      "html", "python", "rust", "bash", "make", "yaml", "toml", "sql", "markdown",
    }
    ts.install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = parsers,
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
