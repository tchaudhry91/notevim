local M = {}

function M.search(notes_dir, query)
	local results = {}
	local title = "Search Results"

	if query and query ~= "" then
		-- Perform content search
		results = M.search_notes(notes_dir, query)
		title = "Search: " .. query
	else
		-- Show recent notes (default 10)
		local recent_files = M.get_recent_notes(notes_dir, 10)
		
		-- Convert to the same format as search results
		for _, filepath in ipairs(recent_files) do
			local relative_path = filepath:gsub("^" .. vim.pesc(notes_dir) .. "/", "")
			table.insert(results, {
				filename = filepath,
				lnum = 1,
				text = "Recent note",
				relative_path = relative_path
			})
		end
		title = "Recent Notes"
	end

	-- Show results using either Telescope or quickfix
	M.show_results(results, { title = title })
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

function M.search_notes(notes_dir, query)
	if not query or query == "" then
		return {}
	end

	-- Check if ripgrep is available
	if vim.fn.executable('rg') == 0 then
		vim.notify("ripgrep (rg) not found. Please install ripgrep for search functionality.", vim.log.levels.ERROR)
		return {}
	end

	-- Escape the query for shell execution
	local escaped_query = vim.fn.shellescape(query)
	
	-- Build ripgrep command
	local cmd = string.format(
		'rg --line-number --with-filename --no-heading --smart-case --glob "*.md" %s %s',
		escaped_query,
		vim.fn.shellescape(notes_dir)
	)

	-- Execute the command
	local output = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	-- Handle errors
	if exit_code ~= 0 and exit_code ~= 1 then
		-- Exit code 1 means no matches, which is fine
		-- Other exit codes indicate real errors
		vim.notify("Search failed: " .. output, vim.log.levels.ERROR)
		return {}
	end

	-- Parse ripgrep output
	local results = {}
	if output and output ~= "" then
		for line in output:gmatch("[^\r\n]+") do
			-- Parse format: filename:line_number:content
			local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
			if filename and lnum and text then
				-- Calculate relative path for display
				local relative_path = filename:gsub("^" .. vim.pesc(notes_dir) .. "/", "")
				
				table.insert(results, {
					filename = filename,
					lnum = tonumber(lnum),
					text = text,
					relative_path = relative_path
				})
			end
		end
	end

	return results
end

function M.show_results(results, opts)
	opts = opts or {}
	local title = opts.title or "Search Results"

	if not results or #results == 0 then
		vim.notify("No results found", vim.log.levels.INFO)
		return
	end

	-- Try to use Telescope if available
	local has_telescope, telescope = pcall(require, 'telescope')
	
	if has_telescope and opts.use_telescope ~= false then
		local pickers = require('telescope.pickers')
		local finders = require('telescope.finders')
		local conf = require('telescope.config').values
		local actions = require('telescope.actions')
		local action_state = require('telescope.actions.state')

		pickers.new(opts, {
			prompt_title = title,
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = string.format("%s:%d: %s", entry.relative_path, entry.lnum, entry.text),
						ordinal = entry.relative_path .. " " .. entry.text,
						filename = entry.filename,
						lnum = entry.lnum,
						col = 1,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd('edit ' .. vim.fn.fnameescape(selection.filename))
						vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
					end
				end)
				return true
			end,
		}):find()
	else
		-- Fallback to quickfix
		local qf_list = {}
		for _, result in ipairs(results) do
			table.insert(qf_list, {
				filename = result.filename,
				lnum = result.lnum,
				col = 1,
				text = result.text,
			})
		end

		vim.fn.setqflist(qf_list)
		vim.cmd('copen')
		vim.notify(string.format("%s (%d results) - using quickfix", title, #results), vim.log.levels.INFO)
	end
end

return M
