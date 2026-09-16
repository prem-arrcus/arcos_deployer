#!/usr/bin/env bash
# Install pre-commit hooks for this repository

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
    echo "Error: .git/hooks not found. Are you in a git repository?"
    exit 1
fi

cp "$REPO_ROOT/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "Pre-commit hook installed successfully!"
echo "It will run shellcheck and shfmt on launch_arcos.sh before each commit."
