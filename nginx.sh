#!/bin/bash
# Clone a GitHub repo and deploy its contents to /var/www/html (nginx root)

set -e

# Ensure git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    sudo apt-get update && sudo apt-get install -y git
fi

REPO_URL="https://github.com/Sirco-team/code-universe.git"  # <-- Hardcoded repo URL

TMP_DIR="/tmp/nginx_repo_clone_$$"
sudo rm -rf /var/www/html/*

# Clone the repo
git clone "$REPO_URL" "$TMP_DIR"

# Copy all contents (not the repo folder itself) to /var/www/html
sudo cp -rT "$TMP_DIR" /var/www/html

# Clean up
echo "Deployed repo contents to /var/www/html."
sudo rm -rf "$TMP_DIR"
