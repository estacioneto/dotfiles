#!/bin/bash

set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
VERSIONS_DIR="$NVM_DIR/versions/node"

if [[ ! -d "$VERSIONS_DIR" ]]; then
  echo "No nvm node versions found at $VERSIONS_DIR" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: nvm-all <npm-command> [args...]"
  echo ""
  echo "Run an npm command across all nvm-installed node versions."
  echo ""
  echo "Examples:"
  echo "  nvm-all install -g tree-sitter-cli"
  echo "  nvm-all list -g --depth=0"
  echo "  nvm-all outdated -g"
  exit 1
fi

failures=0

for node_dir in "$VERSIONS_DIR"/*/; do
  version=$(basename "$node_dir")
  node_bin="$node_dir/bin/node"
  npm_bin="$node_dir/bin/npm"

  if [[ ! -x "$node_bin" || ! -x "$npm_bin" ]]; then
    echo "⚠ $version: node or npm binary not found, skipping"
    continue
  fi

  echo "=== $version ==="

  if PATH="$node_dir/bin:$PATH" "$node_bin" "$npm_bin" "$@"; then
    echo ""
  else
    echo "✗ $version: command failed" >&2
    echo ""
    ((failures++))
  fi
done

if [[ $failures -gt 0 ]]; then
  echo "$failures version(s) failed."
  exit 1
fi
