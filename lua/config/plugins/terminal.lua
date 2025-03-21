return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require('toggleterm').setup({
      direction = 'vertical',
      size = 70, -- Устанавливаете ширину окна терминала
      -- Если хотите добавить другие специфические настройки, можете сделать их здесь
    })
  end
}
