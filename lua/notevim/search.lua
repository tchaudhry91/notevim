local M = {}

function M.search(query)
	if query and query ~= "" then
		print("searching for " .. query)
	else
		print("Showing recent notes")
	end
end

return M
