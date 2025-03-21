return {
    'mfussenegger/nvim-lint',
    config = function()
        require('lint').linters_by_ft = {
            python = {'flake8'},  -- Specify `flake8` for Python files
            -- Add other filetypes and linters as needed
        }
        -- Optionally, set up an autocommand to lint on save
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            callback = function()
                require('lint').try_lint()
            end,
        })
    end
}