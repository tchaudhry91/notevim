local M = {}

M.config = {
	notes_dir = "~/Notes",
}

function M.note(path)
	path = M.config.notes_dir .. "/" .. path
	path = vim.fn.simplify(path)
	path = vim.fn.expand(path)
	if not path:match("%.md$") then
		path = path .. ".md"
	end
	local dir = vim.fn.fnamemodify(path, ":h")
	vim.fn.mkdir(dir, "p")
	local exists = vim.fn.filereadable(path)
	vim.cmd.edit(path)
	if exists == 0 then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, {
			"tags:",
		})
	end
end

function M.search(query)
	require("notevim.search").search(query)
end

function M.sync()
	print("syncing")
end

function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
