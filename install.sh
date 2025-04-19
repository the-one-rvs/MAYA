#!/bin/bash

echo "🚀 Installing Maya CLI..."

# Make all scripts executable
chmod +x maya
chmod +x config.sh
chmod +x pipeline.sh
chmod +x kind.sh
chmod +x input.sh

# Create symbolic link
sudo ln -s "$(pwd)/maya" /usr/local/bin/maya


# Verify installation
if command -v maya &> /dev/null; then
    echo "✅ Maya CLI installed successfully!"
    echo "🎯 Try 'maya --help' to get started"
else
    echo "❌ Installation failed"
    exit 1
fi