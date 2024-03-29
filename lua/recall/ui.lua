local popup = require("plenary.popup")
local Path = require("plenary.path")
local List = require("recall.list")
local vim = vim

local M = {}

-- Popup window (buffer and window id)
local PopupBuffer = nil
local PopupWindow = nil

-- Construct the popup window and buffer
local function create_window(width, height)
    width = width or 80
    height = height or 12
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local win_id, win = popup.create(bufnr, {
        title = "Recall",
        highlight = "RecallWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars
    })

    vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:RecallBorder")

    return { bufnr = bufnr, win_id = win_id }
end

local function get_relative_path(path)
    local cwd = vim.fn.getcwd()
    local rel_path = Path:new(path):make_relative(cwd)
    return rel_path
end

-- Given a history data, construct the lines which we will display in the popup buffer
local function create_content(history_data)
    local contents = {}

    for i, x in ipairs(history_data.data) do
        local nav = i - 1
        local nav_string = tostring(nav)

        if nav == 0 then
            nav_string = "*"
        end

        if nav > 9 then
            nav_string = " "
        end

        local path = get_relative_path(x.path)
        contents[#contents + 1] = string.format("%s %s", nav_string, path)
    end
    return contents
end

-- Set the popup buffer contents, and set some basic options for the buffer
local function set_popup_contents(contents)
    vim.api.nvim_buf_set_name(PopupBuffer, "recall-menu")
    vim.api.nvim_buf_set_lines(PopupBuffer, 0, #contents, false, contents)
    vim.api.nvim_buf_set_option(PopupBuffer, "filetype", "recall")
    vim.api.nvim_buf_set_option(PopupBuffer, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(PopupBuffer, "bufhidden", "delete")
    vim.api.nvim_buf_set_option(PopupBuffer, "modifiable", false)
    if #contents > 0 then
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end
end

-- Create a new popup window, and fill buffer with contents
function M.create_popup(history_data, width, height)
    local popup_info = create_window(width, height)
    PopupWindow = popup_info.win_id
    PopupBuffer = popup_info.bufnr

    local contents = create_content(history_data)
    set_popup_contents(contents)

    return { window = PopupWindow, buffer = PopupBuffer }
end

-- Close the popup window if it is opened
function M.close_popup()
    if PopupWindow ~= nil and vim.api.nvim_win_is_valid(PopupWindow) then
        vim.api.nvim_win_close(PopupWindow, true)
        PopupWindow = nil
        PopupBuffer = nil
        return true
    end
    return false
end

return M
