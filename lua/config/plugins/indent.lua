return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = '|',  -- символ для вертикальных линий
    },
    scope = {
      enabled = false,  -- отключаем выделение текущего контекста
    },
  },
}