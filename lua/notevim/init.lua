local M = {}

M.config = {
	notes_dir = "~/Notes",
}

function M.note(path)
	-- Validate input path to prevent directory traversal
	if not path or path == "" then
		vim.notify("Path cannot be empty", vim.log.levels.ERROR)
		return
	end
	
	-- Prevent path traversal attacks
	if path:match("%.%.") or path:match("^/") or path:match("^~") then
		vim.notify("Invalid path: relative paths (../), absolute paths (/), and home paths (~) are not allowed", vim.log.levels.ERROR)
		return
	end
	
	-- Remove any leading/trailing slashes
	path = path:gsub("^/+", ""):gsub("/+$", "")
	
	-- Construct full path
	path = M.config.notes_dir .. "/" .. path
	path = vim.fn.simplify(path)
	path = vim.fn.expand(path)
	
	-- Ensure the final path is still within notes_dir (defense in depth)
	local expanded_notes_dir = vim.fn.expand(M.config.notes_dir)
	if not path:find("^" .. vim.pesc(expanded_notes_dir)) then
		vim.notify("Invalid path: resolved path is outside notes directory", vim.log.levels.ERROR)
		return
	end
	
	if not path:match("%.md$") then
		path = path .. ".md"
	end
	
	local dir = vim.fn.fnamemodify(path, ":h")
	
	-- Add error handling for directory creation
	local success, err = pcall(vim.fn.mkdir, dir, "p")
	if not success then
		vim.notify("Failed to create directory: " .. dir .. " (" .. tostring(err) .. ")", vim.log.levels.ERROR)
		return
	end
	
	local exists = vim.fn.filereadable(path)
	
	-- Add error handling for file editing
	local edit_success, edit_err = pcall(vim.cmd.edit, path)
	if not edit_success then
		vim.notify("Failed to open file: " .. path .. " (" .. tostring(edit_err) .. ")", vim.log.levels.ERROR)
		return
	end
	
	if exists == 0 then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, {
			"tags:",
		})
	end
end

function M.search(query)
	require("notevim.search").search(M.config.notes_dir, query)
end

function M.sync()
	local notes_dir = M.config.notes_dir
	
	-- Check if git is available
	if vim.fn.executable('git') == 0 then
		vim.notify("Git not found. Please install git for sync functionality.", vim.log.levels.ERROR)
		return
	end

	-- Change to notes directory with proper validation
	local original_cwd = vim.fn.getcwd()
	local expanded_notes_dir = vim.fn.expand(notes_dir)
	
	-- Validate notes directory exists
	if vim.fn.isdirectory(expanded_notes_dir) == 0 then
		vim.notify("Notes directory does not exist: " .. expanded_notes_dir, vim.log.levels.ERROR)
		return
	end
	
	local escaped_notes_dir = vim.fn.fnameescape(expanded_notes_dir)
	local success, err = pcall(vim.cmd, 'cd ' .. escaped_notes_dir)
	if not success then
		vim.notify("Failed to access notes directory: " .. expanded_notes_dir .. " (" .. tostring(err) .. ")", vim.log.levels.ERROR)
		return
	end

	-- Check if this is a git repository
	local git_check = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null')
	if vim.v.shell_error ~= 0 then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("Notes directory is not a git repository. Run 'git init' in " .. notes_dir, vim.log.levels.ERROR)
		return
	end

	vim.notify("Starting sync...", vim.log.levels.INFO)

	-- Pull changes first
	vim.notify("Pulling remote changes...", vim.log.levels.INFO)
	local pull_output = vim.fn.system('git pull 2>&1')
	if vim.v.shell_error ~= 0 then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("Git pull failed: " .. pull_output, vim.log.levels.ERROR)
		return
	end

	-- Check for uncommitted changes
	local status_output = vim.fn.system('git status --porcelain')
	if status_output == "" then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("No changes to sync", vim.log.levels.INFO)
		return
	end

	-- Add all changes
	vim.notify("Adding changes...", vim.log.levels.INFO)
	local add_output = vim.fn.system('git add . 2>&1')
	if vim.v.shell_error ~= 0 then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("Git add failed: " .. add_output, vim.log.levels.ERROR)
		return
	end

	-- Create commit message with timestamp
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local commit_msg = string.format("Auto-sync notes: %s", timestamp)
	
	-- Commit changes
	vim.notify("Committing changes...", vim.log.levels.INFO)
	local commit_output = vim.fn.system(string.format('git commit -m %s 2>&1', vim.fn.shellescape(commit_msg)))
	if vim.v.shell_error ~= 0 then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("Git commit failed: " .. commit_output, vim.log.levels.ERROR)
		return
	end

	-- Push changes
	vim.notify("Pushing to remote...", vim.log.levels.INFO)
	local push_output = vim.fn.system('git push 2>&1')
	if vim.v.shell_error ~= 0 then
		vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
		vim.notify("Git push failed: " .. push_output .. "\nChanges are committed locally.", vim.log.levels.WARN)
		return
	end

	-- Restore original directory
	vim.cmd('cd ' .. vim.fn.fnameescape(original_cwd))
	
	vim.notify("✓ Sync completed successfully!", vim.log.levels.INFO)
end

function M.setup(opts)
	opts = opts or {}
	
	-- Validate configuration options
	if opts.notes_dir and type(opts.notes_dir) ~= "string" then
		vim.notify("Invalid notes_dir: must be a string", vim.log.levels.ERROR)
		return
	end
	
	M.config = vim.tbl_deep_extend("force", M.config, opts)
	M.config.notes_dir = vim.fn.simplify(M.config.notes_dir)
	M.config.notes_dir = vim.fn.expand(M.config.notes_dir)
	
	-- Ensure notes directory exists
	if vim.fn.isdirectory(M.config.notes_dir) == 0 then
		local success, err = pcall(vim.fn.mkdir, M.config.notes_dir, "p")
		if not success then
			vim.notify("Failed to create notes directory: " .. M.config.notes_dir, vim.log.levels.ERROR)
		end
	end
end

return M
