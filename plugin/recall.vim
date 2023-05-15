augroup AutoRecallGroup
    autocmd!
    autocmd BufUnload * lua require("recall").store_position()
    autocmd BufLeave * lua require("recall").save_position()
    autocmd VimEnter * lua require("recall").load()
augroup END

command! RecallToggle lua require("recall").toggle()
command! RecallClearHistory lua require("recall").clear_history()
