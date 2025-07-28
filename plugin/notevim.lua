vim.api.nvim_create_user_command("Note", function(opts)
	require("notevim").note(opts.args)
end, {
	nargs = 1,
	desc = "Create a Note",
})

vim.api.nvim_create_user_command("NoteSearch", function(opts)
	require("notevim").search(opts.args)
end, {
	nargs = "?",
	desc = "Search your notes",
})

vim.api.nvim_create_user_command("NoteSync", function(opts)
	require("notevim").sync()
end, {
	desc = "Bidirectional Note Sync",
})
