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
    file_ignore_patterns = {"env/", "venv/", "env16/", "env18/", "env22/"},
  }
}

local builtin = require('telescope.builtin')

-- Function to determine the root directory
local function get_root_dir()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  return git_root and #git_root > 0 and git_root or vim.loop.cwd()
end

-- Custom function to search files in the project root
local function project_files()
  local opts = { cwd = get_root_dir() } -- Set the working directory to the root directory
  builtin.find_files(opts)
end

-- Custom function to live grep in the project root
local function project_live_grep()
  local opts = { cwd = get_root_dir() } -- Set the working directory to the root directory
  builtin.live_grep(opts)
end

-- Key mappings
vim.keymap.set('n', '<leader>ff', project_files, { desc = 'Telescope find files in project' })
vim.keymap.set('n', '<leader>fg', project_live_grep, { desc = 'Telescope live grep in project' })
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
vim.keymap.set('n', '<C-\\>', '<Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })
