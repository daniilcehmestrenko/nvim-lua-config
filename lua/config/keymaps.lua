-- Создаем локальную переменную чтобы упростить процесс
local map = vim.api.nvim_set_keymap

-- Опции для биндов (пример: без вставки в историю, без рекурсии)
local opts = { noremap = true, silent = true }

-- Настройки для netrw
vim.g.netrw_banner = 0          -- Отключение рекламного баннера
vim.g.netrw_keepdir = 0         -- Изменять текущую директорию на выбранную в netrw
vim.g.netrw_liststyle = 3       -- Использовать дерево для просмотра

-- Глобальная таблица для хранения состояния
_G.netrw_state = {}

-- Объявление функции в глобальной области
function _G.toggleNetrw()
  -- Получаем список всех открытых окон
  local windows = vim.api.nvim_tabpage_list_wins(0)
  -- Проверяем, открыт ли Netrw уже
  for _, win in ipairs(windows) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if string.find(bufname, 'NetrwTreeListing') or string.find(bufname, 'NERD') then
      -- Проверяем, доступен ли буфер, и закрываем его, если он валиден
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd("bwipeout")
      else
        vim.cmd("bwipeout!")
      end
      -- Переключаемся обратно на последний буфер, если он доступен
      if _G.netrw_state.prev_buf and vim.api.nvim_buf_is_valid(_G.netrw_state.prev_buf) then
        vim.cmd('buffer ' .. _G.netrw_state.prev_buf)
      end
      return
    end
  end
  -- Сохраняем текущий буфер
  _G.netrw_state.prev_buf = vim.fn.bufnr()
  -- Открываем Netrw
  vim.cmd("Explore")
end

-- Привязываем функцию к <leader>e
vim.api.nvim_set_keymap('n', '<leader>e', ':lua toggleNetrw()<CR>', { noremap = true, silent = true, desc = 'Открыть/закрыть дерево файлов' })

-- Настройка bufferline
require('bufferline').setup {
  options = {
    numbers = "ordinal",
    show_buffer_close_icons = true,
    show_close_icon = false,
    separator_style = "thin",
    diagnostics = "nvim_lsp",
    offsets = {{ filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 1 }},
  }
}
-- Настройка авто-команды для переключения между буферами с помощью Tab и Shift+Tab
vim.api.nvim_set_keymap('n', '<Tab>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })

-- Установка для безопасного удаления буферов
vim.api.nvim_set_keymap('n', '<leader>bd', ':BufDel<CR>', { noremap = true, silent = true })

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
  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.rename, opts)

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
local Terminal  = require('toggleterm.terminal').Terminal

-- Определяем терминал с опциями focus=true
local my_terminal = Terminal:new({
  hidden = true,
  direction = 'float', -- или 'vertical', 'horizontal', 'tab'
  close_on_exit = true,
  on_open = function(term)
    -- Фокус на терминале, когда он открывается
    vim.cmd('startinsert!')
  end,
})

-- Функция для переключения
function _G.toggle_my_terminal()
  if my_terminal:is_open() then
    my_terminal:close()
    -- Переключаем фокус обратно на файл
    vim.cmd('wincmd p')
  else
    -- Установите рабочую директорию в начальную директорию nvim
    local initial_dir = vim.fn.getcwd(-1, -1)  -- Использует первоначальную директорию запуска neovim
    vim.cmd('lcd ' .. initial_dir)
    my_terminal:open()
  end
end

-- Привязываем к ctrl-\
vim.api.nvim_set_keymap('n', '<C-\\>', '<Cmd>lua toggle_my_terminal()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-\\>', '<Cmd>lua toggle_my_terminal()<CR>', { noremap = true, silent = true })
