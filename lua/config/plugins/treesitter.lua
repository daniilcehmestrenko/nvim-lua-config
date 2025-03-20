return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = {
              "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript",
              "html", "python", "rust", "bash", "make", "yaml", "toml", "sql", "markdown"
          },
          sync_install = false,  -- Опционально, устанавливает парсеры асинхронно
          highlight = {
              enable = true,  -- Включает подсветку синтаксиса
          },
          indent = {
              enable = true,  -- Включает автоматическое определение отступов
          },
      })
    end
}