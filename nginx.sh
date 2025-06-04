#!/bin/bash
# Clone a GitHub repo and deploy its contents to /var/www/html (nginx root)

set -e

REPO_URL="https://github.com/yourusername/your-repo.git"  # <-- Hardcoded repo URL

TMP_DIR="/tmp/nginx_repo_clone_$$"
sudo rm -rf /var/www/html/*

# Clone the repo
git clone "$REPO_URL" "$TMP_DIR"

# Copy all contents (not the repo folder itself) to /var/www/html
sudo cp -rT "$TMP_DIR" /var/www/html

# Clean up
echo "Deployed repo contents to /var/www/html."
sudo rm -rf "$TMP_DIR"
