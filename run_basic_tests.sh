#!/bin/bash

echo "Running basic NoteVim tests..."

# Create test directory
mkdir -p /tmp/test-notes

# Run the basic test with proper runtime path
nvim --headless \
  -c "set runtimepath+=$(pwd)" \
  -c "luafile tests/basic_test.lua" \
  -c "qa!"

echo "Basic tests completed!"