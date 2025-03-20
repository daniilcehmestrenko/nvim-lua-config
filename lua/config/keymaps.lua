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
    file_ignore_patterns = {"env/", "venv/"},
  }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Telescope buffer fuzzy find' })

-- Настройки LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.keymap.set({ 'n', 'v' }, '<leader>r', vim.lsp.buf.rename, { buffer = args.buf })
    vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, { buffer = args.buf })
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    vim.keymap.set('n', '<leader>jr', vim.lsp.buf.references, { buffer = args.buf })
    local opts = { buffer = args.buf }
    vim.keymap.set('n', '<leader>jD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, { buffer = args.buf })
    end
    vim.keymap.set('n', '<leader>ji', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-i>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>l', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    -- Автокоманда для отображения всплывающего окна с диагностикой
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = args.buf,
      callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
      end
    })
  end,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- Disable signs
    signs = false,
  }
)

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')

