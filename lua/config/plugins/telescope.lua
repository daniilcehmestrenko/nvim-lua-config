return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup{
            defaults = {
                sorting_strategy = "ascending",  -- Или "descending" в зависимости от ваших предпочтений
            }
        }
    end
}