local M = {}

function M.reload()
	require("plenary.reload").reload_module("recall")
end

return M
