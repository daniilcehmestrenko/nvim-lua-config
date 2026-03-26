return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        -- по желанию:
        -- ensure_installed = { "pyright", "ts_ls", "rust_analyzer" },

        handlers = {
          -- дефолтный хэндлер для всех серверов
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,

          -- пример: кастом для конкретного сервера
          -- pyright = function()
          --   require("lspconfig").pyright.setup({ settings = { ... } })
          -- end,
        },
      })
    end,
  },
}
