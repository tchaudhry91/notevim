local M = {}

function M.note(path)
	print("Creating note..." .. path)
end

function M.search(query)
	require("notevim.search").search(query)
end

function M.sync()
	print("syncing")
end

function M.setup()
	print("some setup")
end

return M
