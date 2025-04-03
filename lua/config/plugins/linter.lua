return {
    'mfussenegger/nvim-lint',
    config = function()
        require('lint').linters_by_ft = {
            python = {'flake8'},  -- Укажите flake8 для файлов Python
            rust = {'cargo'},     -- Используем стандартный сборщик Cargo для проверки синтаксиса
        }

        require('lint').linters.cargo = {
            cmd = 'cargo',             -- Указываем Cargo как инструмент для линтинга
            stdin = false,             -- Cargo не использует стандартный ввод
            args = {'clippy'},          -- Команда для выполнения проверки
            append_fname = false,      -- Не добавляем имя файла, Cargo работает в контексте проекта
            ignore_exitcode = false,   -- Не игнорируем код выхода, чтобы отображать ошибки
            parser = require('lint.parser').from_errorformat(
                '%f:%l:%c: %t: %m',
                {
                    source = 'cargo',
                    severity_map = {
                        ['E'] = vim.diagnostic.severity.ERROR,
                        ['W'] = vim.diagnostic.severity.WARN,
                        ['I'] = vim.diagnostic.severity.INFO,
                        ['N'] = vim.diagnostic.severity.HINT,
                    }
                }
            )
        }

        -- Опционально, настройте автокоманду для линтинга при сохранении
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            callback = function()
                require('lint').try_lint()
            end,
        })
    end
}
