local notevim = require('notevim')

-- Basic setup test
print("Testing setup...")
notevim.setup({ notes_dir = "/tmp/test-notes" })
print("✓ Setup completed")

-- Test note creation with valid path
print("Testing note creation...")
local test_path = "test/sample"
notevim.note(test_path)
print("✓ Note creation test completed")

-- Test invalid path (should fail)
print("Testing invalid path...")
notevim.note("../invalid")
print("✓ Invalid path test completed")

-- Test search function
print("Testing search...")
notevim.search()
print("✓ Search test completed")

-- Test sync function
print("Testing sync...")
notevim.sync()
print("✓ Sync test completed")

print("All basic tests completed!")