-- Создаем локальную переменную чтобы упростить процесс
local map = vim.api.nvim_set_keymap

-- Опции для биндов (пример: без вставки в историю, без рекурсии)
local opts = { noremap = true, silent = true }

-- Настройки для netrw
vim.g.netrw_banner = 0          -- Отключение рекламного баннера
vim.g.netrw_keepdir = 0         -- Изменять текущую директорию на выбранную в netrw
vim.g.netrw_liststyle = 3       -- Использовать дерево для просмотра
map('n', '<leader>e', ':Explore<CR>', opts)

-- Настройки Telescope
local status, telescope = pcall(require, "telescope")
if not status then
  return
end

telescope.setup {
  defaults = {
    -- Эти настройки применяются во время поиска файлов
    file_ignore_patterns = {"env/", "venv/", "env16/", "env18/", "env22/"},
  }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Telescope buffer fuzzy find' })

-- Настройки LSP
-- LSP конфигурация
local nvim_lsp = require('lspconfig')

-- Основная функция привязки
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- Настройки keymap
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, opts)

  -- Создаем автокоманду для диагностики
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end,
  })
end

-- Определяем функцию для получения пути до интерпретатора
local function get_python_path(workspace)
  -- Используем venv
  local venv = vim.fn.getenv('VIRTUAL_ENV')
  if venv ~= vim.NIL and venv ~= '' then
    return venv .. '/bin/python'
  end
  -- Фолбек на системный Python, если VIRTUAL_ENV не установлен
  return '/usr/bin/python'
end

nvim_lsp.pyright.setup{
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = get_python_path(vim.fn.getcwd()),
      analysis = {
        extraPaths = { "lib" },  -- добавляем папку lib как дополнительный путь
      },
    },
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = false,
      }
    ),
  },
}

-- Добавьте подобные конфигурации для других LSP серверов
-- Например, для tsserver (TypeScript/JavaScript)
-- nvim_lsp.tsserver.setup{
--   on_attach = on_attach  -- Используем ту же функцию on_attach
-- }

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')

