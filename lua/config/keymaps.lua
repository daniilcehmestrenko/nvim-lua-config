-- Создаем локальную переменную чтобы упростить процесс
local map = vim.api.nvim_set_keymap

-- Опции для биндов (пример: без вставки в историю, без рекурсии)
local opts = { noremap = true, silent = true }

-- Настройки для netrw
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 1
vim.g.netrw_liststyle = 1

-- Глобальная таблица для хранения состояния
_G.netrw_state = {}

-- Объявление функции в глобальной области
function _G.toggleNetrw()
  local current_win = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_tabpage_list_wins(0)

  -- Поиск окна Netrw
  for _, win in ipairs(windows) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    
    if vim.bo[bufnr].filetype == 'netrw' then
      -- Если Netrw открыт, переключаемся на предыдущий буфер
      if _G.netrw_state.prev_buf and vim.api.nvim_buf_is_valid(_G.netrw_state.prev_buf) then
        vim.api.nvim_set_current_win(_G.netrw_state.prev_win)
        vim.cmd('buffer ' .. _G.netrw_state.prev_buf)
      end
      return
    end
  end

  -- Сохраняем текущие окно и буфер перед открытием Netrw
  _G.netrw_state.prev_win = current_win
  _G.netrw_state.prev_buf = vim.api.nvim_get_current_buf()

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
  local opts = {
    cwd = get_root_dir(),
    additional_args = function()
      return {"--fixed-strings"}  -- Это заставит 'rg' искать полные соответствия строк
    end
  }
  builtin.live_grep(opts)
end

-- Key mappings
vim.keymap.set('n', '<leader>ff', project_files, { desc = 'Telescope find files in project' })
vim.keymap.set('n', '<leader>fg', project_live_grep, { desc = 'Telescope live grep in project' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Telescope buffer fuzzy find' })

local nvim_lsp = require('lspconfig')

-- Включаем поддержку сортировки по серьезности
vim.diagnostic.config({
  virtual_text = false,  -- Выключаем виртуальный текст, чтобы не мешал
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Определяем знаки для различных уровней диагностики
local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Основная функция привязки
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.rename, opts)

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end,
  })
end

local function get_python_path(workspace)
  local venv = vim.fn.getenv('VIRTUAL_ENV')
  if venv ~= vim.NIL and venv ~= '' then
    return venv .. '/bin/python'
  end
  return '/usr/bin/python'
end

nvim_lsp.pyright.setup{
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = get_python_path(vim.fn.getcwd()),
      analysis = {
        extraPaths = { "lib" },
      },
    },
  },
}

nvim_lsp.rust_analyzer.setup{
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
}

-- Вы также можете определить цвета для диагностики в вашей `init.vim` или `init.lua`:
-- Терялся при поиске?
vim.cmd [[
  highlight DiagnosticError guifg=Red
  highlight DiagnosticWarn guifg=Orange
  highlight DiagnosticInfo guifg=Blue
  highlight DiagnosticHint guifg=Green
]]

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
