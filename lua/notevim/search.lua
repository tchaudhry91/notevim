local M = {}

function M.search(notes_dir, query)
	if query and query ~= "" then
		print("searching for " .. query)
	else
		print("Showing recent notes")
	end
end

function M.get_recent_notes(notes_dir, limit)
	local pattern = "/**/*.md"
	local files = vim.fn.glob(notes_dir .. pattern, false, true)
	local files_with_time = {}
	for i, filepath in ipairs(files) do
		local mod_time = vim.fn.getftime(filepath)
		table.insert(files_with_time, {
			note = filepath,
			mod_time = mod_time,
		})
	end
	table.sort(files_with_time, function(a, b)
		return a.mod_time > b.mod_time
	end)
	local result = {}
	for i = 1, limit do
		if files_with_time[i] then
			table.insert(result, files_with_time[i].note)
		end
	end
	return result
end

function M.search_notes(notes_dir, query) end

function M.show_results(results) end

return M
