
-- ~/.config/nvim/init.lua

-- Базовые настройки
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Встроенный LSP (Neovim 0.11+)
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'compile_commands.json', '.git' },
})
vim.lsp.enable('clangd')

-- Автодополнение из коробки (Neovim 0.11+)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'clangd' then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

-- Хоткеи для LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
  end,
})

-- ==========================================
-- КОМПИЛЯЦИЯ И ЗАПУСК C В КРАСИВОМ ОКНЕ
-- ==========================================
vim.keymap.set("n", "rr", function()
    -- 1. Проверяем, что файл сохранен на диск
    if vim.fn.expand("%:p") == "" then
        print("Ошибка: Сначала сохрани файл с расширением .c!")
        return
    end
    vim.cmd("w") -- Сохраняем файл перед компиляцией

    -- 2. Получаем абсолютный путь к файлу и экранируем пробелы
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))

    -- 3. Создаем буфер и всплывающее окно
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded", -- Скругленные углы в стиле Cybercore
        title = " [ C Build & Run ] ",
        title_pos = "center",
    })

    -- 4. Команда компиляции и запуска
    -- Добавил -Wall -Wextra, чтобы компилятор сразу ругался на твои косяки
    local cmd = "gcc " .. file .. " -Wall -Wextra -o /tmp/a.out && /tmp/a.out"
    vim.fn.termopen(cmd)

    -- ==========================================
    -- ХОТКЕИ ДЛЯ УПРАВЛЕНИЯ ОКНОМ
    -- ==========================================

    -- Выход из режима терминала в Normal mode (чтобы скопировать текст)
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buf, nowait = true })

    -- Мгновенное закрытие из терминала (если программа зависла на scanf)
    vim.keymap.set("t", "<C-t>", "<C-\\><C-n>:bd!<CR>", { buffer = buf, nowait = true })

    -- Закрытие из Normal mode (нажми q, когда курсор внутри окна)
    vim.keymap.set("n", "q", ":bd!<CR>", { buffer = buf, nowait = true })
end, { desc = "Compile and Run C in floating window" })

-- Навигация по ошибкам компиляции (нативный Quickfix)
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "Open Quickfix" })
vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { desc = "Next Error" })
vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { desc = "Prev Error" })

-- ==========================================
-- DARK CYBERCORE THEME (Pure Lua)
-- ==========================================
vim.opt.background = "dark"

-- Базовые цвета
local bg       = "#0a0a0a" -- Глубокий черный
local fg       = "#e0e0e0" -- Светло-серый текст
local neon_cy  = "#00ffff" -- Неоновый циан (переменные)
local neon_gr  = "#00ff41" -- Матричный зеленый (строки/ключевые слова)
local neon_pu  = "#bd00ff" -- Кибер-фиолетовый (функции)
local comment  = "#555555" -- Темно-серый для комментов

-- Сброс старых цветов (на всякий случай)
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end

-- Применяем наши цвета
vim.api.nvim_set_hl(0, "Normal",       { bg = bg, fg = fg })
vim.api.nvim_set_hl(0, "Comment",      { fg = comment, italic = true })
vim.api.nvim_set_hl(0, "String",       { fg = neon_gr })
vim.api.nvim_set_hl(0, "Function",     { fg = neon_pu, bold = true })
vim.api.nvim_set_hl(0, "Keyword",      { fg = neon_gr, bold = true })  -- if, return, int
vim.api.nvim_set_hl(0, "Type",         { fg = neon_cy, bold = true })  -- char, float
vim.api.nvim_set_hl(0, "Variable",     { fg = neon_cy })
vim.api.nvim_set_hl(0, "Number",       { fg = neon_pu })
vim.api.nvim_set_hl(0, "Operator",     { fg = fg })                    -- +, -, =

-- Цвета интерфейса (номера строк, курсор)
vim.api.nvim_set_hl(0, "LineNr",       { fg = comment })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = neon_gr, bold = true })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#151515" })
vim.api.nvim_set_hl(0, "Visual",       { bg = "#2a2a2a" })              -- Выделение
vim.api.nvim_set_hl(0, "Normal", { bg = "none", fg = fg }) -- Убирает фон Neovim
-- Красивые ошибки
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#ff003c", bold = true }) -- Кроваво-красный
vim.api.nvim_set_hl(0, "WarningMsg", { fg = neon_pu })              -- Фиолетовый
vim.api.nvim_set_hl(0, "Error", { fg = "#ff003c" })
-- Быстрое закрытие терминала: Ctrl + t
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>:q<CR>", { desc = "Close terminal" })

