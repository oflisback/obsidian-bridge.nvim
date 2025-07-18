#!/usr/bin/env bash
set -e
echo "🔧 Formatting Lua files with stylua..."

# Check if stylua is available
if ! command -v stylua &> /dev/null; then
    echo "❌ Error: stylua is not installed or not in PATH"
    echo "Install with: cargo install stylua"
    exit 1
fi

stylua lua/

echo "✅ Formatting complete!"
