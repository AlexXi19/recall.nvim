local List = require("recall.list")
local Ui = require("recall.ui")
local Path = require("plenary.path")
local vim = vim

local M = {}

-- This is where we store the history
local CacheDir = string.format("%s/recall", vim.fn.stdpath("data"))
-- local CachePath = Path:new(string.format("%s/recall.json", vim.fn.stdpath("data")))

local function get_cache_path()
    local cwd = vim.fn.getcwd()
    local valid_chars = "[^a-zA-Z0-9_-]" -- Define a pattern for invalid characters
    local replacement_char = "_"         -- The character to replace invalid characters with
    local string_cwd = string.format("%s/%s.json", CacheDir, string.gsub(cwd, valid_chars, replacement_char))
    return Path:new(string_cwd)
end

local function create_data()
    return List.new(vim.g.recall_history)
end

-- History data is stored here
local HistoryData = create_data()

-- https://vi.stackexchange.com/a/34983/38739 - this is why vim.fn.expand("%:p") is not good
local function get_current_buffer_info()
    local path_to_file = vim.fn.expand("<afile>:p")
    local cursor_info = vim.api.nvim_win_get_cursor(0)
    return { path = path_to_file, line = cursor_info[1], character = cursor_info[2] }
end

local function create_directory_if_not_exists(directory_path)
    local dir = Path:new(directory_path)
    if not dir:exists() then
        dir:mkdir({ parents = true })
    end
end

-- Add an entry to the list with the given predefined format
local function add_item_to_list(path, line_number, char_number)
    local data_table = { path = path, line_number = line_number, char_number = char_number, date = os.date("*t") }
    List.add(HistoryData, data_table, function(x) return x.path end)
end

function M.toggle()
    local is_closed = Ui.close_popup()
    if is_closed then
        return
    end

    local popup_info = Ui.create_popup(HistoryData, vim.g.recall_window_width, vim.g.recall_window_height)

    -- vim.cmd(string.format(
    -- "autocmd BufLeave <buffer=%d> lua require('recall').toggle()",
    -- popup_info.buffer
    -- ))

    -- Keymappings for the opened popup window
    local exit_mappings = { "<C-c>", "q", "<Esc>" }

    for _, value in pairs(exit_mappings) do
        vim.api.nvim_buf_set_keymap(popup_info.buffer, "n", value, ":lua require('recall').toggle()<CR>",
            { noremap = true, silent = true })
    end

    vim.api.nvim_buf_set_keymap(
        popup_info.buffer,
        "n",
        "<CR>",
        ":lua require('recall').open_selected()<CR>",
        { silent = true }
    )

    local max_nav = math.min(vim.g.recall_history, #HistoryData.data, 9)
    for i = 1, max_nav do
        vim.api.nvim_buf_set_keymap(
            popup_info.buffer,
            "n",
            tostring(i),
            string.format(":lua require('recall').navigate_with_input(%d)<CR>", i),
            { silent = true }
        )
    end
end

-- Record file path, line number and char position, then write to a file and save the file
function M.save_position()
    local info = get_current_buffer_info()
    if (info.path ~= nil and info.path ~= "" and Path:new(info.path):exists()) then
        add_item_to_list(info.path, info.line, info.character)
    end
end

-- Record file path, line number and char position, then write to a file and save the file
function M.store_position()
    local info = get_current_buffer_info()
    if (info.path ~= nil and info.path ~= "" and Path:new(info.path):exists()) then
        add_item_to_list(info.path, info.line, info.character)
        M.save()
    end
end

local function navigate(number)
    local selected_item = HistoryData.data[number]
    Ui.close_popup()
    vim.api.nvim_command(string.format("e %s", selected_item.path))
    vim.api.nvim_command(string.format(":%d", selected_item.line_number))
end

function M.navigate_with_input(number)
    navigate(number + 1)
end

-- Open the selected (rfom popup buffer) file in a new buffer at the defined line number
function M.open_selected()
    local line_number, _ = unpack(vim.api.nvim_win_get_cursor(0))
    navigate(line_number)
end

-- Save history to the defined cache file
function M.save()
    local cache_path = get_cache_path()
    cache_path:write(List.to_json(HistoryData), "w")
end

-- Load history from the defined cached file
function M.load()
    local cache_path = get_cache_path()
    if cache_path:exists() ~= true then
        -- If the cache file does not exists, let's create it with the empty data holder
        M.save()
    end
    List.from_json(HistoryData, cache_path:read())
end

-- Remove all items from the history (clear the cache file as well)
function M.clear_history()
    HistoryData = create_data()
    -- We just overwrite the file with an empty table
    M.save()
end

function M.setup(opts)
    create_directory_if_not_exists(CacheDir)

    local function set_default(opt, default)
        local prefix = "recall_"
        if vim.g[prefix .. opt] ~= nil then
            return
        elseif opts[opt] ~= nil then
            vim.g[prefix .. opt] = opts[opt]
        else
            vim.g[prefix .. opt] = default
        end
    end

    set_default("history", 20)
    set_default("window_width", 70)
    set_default("window_height", 14)
end

-- Default setup
M.setup({})

return M
