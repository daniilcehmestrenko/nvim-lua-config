return {
  'lewis6991/gitsigns.nvim',
  version = "*",
  config = function()
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitGutterAdd' })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'GitGutterChange' })
    vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { link = 'GitGutterChange' })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'GitGutterDelete' })
    vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { link = 'GitGutterDelete' })
    
    require('gitsigns').setup({
      -- Настройки Gitsigns без устаревших и неверных полей
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      signcolumn = true,
      numhl      = false,
      linehl     = false,
      word_diff  = false,
      watch_gitdir = { interval = 1000 },
      current_line_blame = false,
      sign_priority = 6,
      update_debounce = 100,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    })
  end
}
