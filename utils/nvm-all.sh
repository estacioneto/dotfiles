#!/bin/bash

set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
VERSIONS_DIR="$NVM_DIR/versions/node"

if [[ ! -d "$VERSIONS_DIR" ]]; then
  echo "No nvm node versions found at $VERSIONS_DIR" >&2
  exit 1
fi

# Temp directory for snapshots (cleaned up on exit)
TMPDIR_NVM_ALL=$(mktemp -d)
trap 'rm -rf "$TMPDIR_NVM_ALL"' EXIT

if [[ $# -lt 1 ]]; then
  echo "Usage: nvm-all <npm-command> [args...]"
  echo ""
  echo "Run an npm command across all nvm-installed node versions."
  echo "When -g/--global is used, prints a summary of package changes."
  echo ""
  echo "Examples:"
  echo "  nvm-all install -g tree-sitter-cli"
  echo "  nvm-all upgrade -g"
  echo "  nvm-all list -g --depth=0"
  echo "  nvm-all outdated -g"
  exit 1
fi

# Detect global flag for package change summary
should_snapshot=false
for arg in "$@"; do
  if [[ "$arg" == "-g" || "$arg" == "--global" ]]; then
    should_snapshot=true
    break
  fi
done

if [[ "$should_snapshot" == true ]]; then
  if ! command -v jq &>/dev/null; then
    echo "⚠ jq not found — upgrade summary will not be available"
    should_snapshot=false
  fi
fi

has_changes=false

failures=0

for node_dir in "$VERSIONS_DIR"/*/; do
  version=$(basename "$node_dir")
  node_bin="$node_dir/bin/node"
  npm_bin="$node_dir/bin/npm"

  if [[ ! -x "$node_bin" || ! -x "$npm_bin" ]]; then
    echo "⚠ $version: node or npm binary not found, skipping"
    continue
  fi

  # Snapshot before
  if [[ "$should_snapshot" == true ]]; then
    PATH="$node_dir/bin:$PATH" "$node_bin" "$npm_bin" list -g --depth=0 --json 2>/dev/null \
      | jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value.version)"' \
      | sort > "$TMPDIR_NVM_ALL/${version}_before" || true
  fi

  echo "=== $version ==="

  if PATH="$node_dir/bin:$PATH" "$node_bin" "$npm_bin" "$@"; then
    echo ""
  else
    echo "✗ $version: command failed" >&2
    echo ""
    ((failures++))
  fi

  # Snapshot after and diff
  if [[ "$should_snapshot" == true ]]; then
    PATH="$node_dir/bin:$PATH" "$node_bin" "$npm_bin" list -g --depth=0 --json 2>/dev/null \
      | jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value.version)"' \
      | sort > "$TMPDIR_NVM_ALL/${version}_after" || true

    # Find changes: added, removed, updated
    diff_file="$TMPDIR_NVM_ALL/${version}_diff"
    added=$(comm -13 "$TMPDIR_NVM_ALL/${version}_before" "$TMPDIR_NVM_ALL/${version}_after")
    removed=$(comm -23 "$TMPDIR_NVM_ALL/${version}_before" "$TMPDIR_NVM_ALL/${version}_after")

    # Extract just package names from before/after for version comparison
    before_pkgs=$(sed 's/@[^@]*$//' "$TMPDIR_NVM_ALL/${version}_before" | sort)
    after_pkgs=$(sed 's/@[^@]*$//' "$TMPDIR_NVM_ALL/${version}_after" | sort)

    : > "$diff_file"

    # Updated packages: present in both before and after but with different versions
    while IFS= read -r pkg_name; do
      before_entry=$(grep "^${pkg_name//./\\.}@" "$TMPDIR_NVM_ALL/${version}_before" || true)
      after_entry=$(grep "^${pkg_name//./\\.}@" "$TMPDIR_NVM_ALL/${version}_after" || true)

      if [[ -n "$before_entry" && -n "$after_entry" && "$before_entry" != "$after_entry" ]]; then
        old_ver="${before_entry##*@}"
        new_ver="${after_entry##*@}"
        echo "updated ${pkg_name} ${old_ver} ${new_ver}" >> "$diff_file"
        has_changes=true
      fi
    done <<< "$(comm -12 <(echo "$before_pkgs") <(echo "$after_pkgs"))"

    # Newly added packages (name not in before)
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      pkg_name="${entry%@*}"
      new_ver="${entry##*@}"
      if ! grep -q "^${pkg_name//./\\.}@" "$TMPDIR_NVM_ALL/${version}_before" 2>/dev/null; then
        echo "added ${pkg_name} ${new_ver}" >> "$diff_file"
        has_changes=true
      fi
    done <<< "$added"

    # Removed packages (name not in after)
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      pkg_name="${entry%@*}"
      old_ver="${entry##*@}"
      if ! grep -q "^${pkg_name//./\\.}@" "$TMPDIR_NVM_ALL/${version}_after" 2>/dev/null; then
        echo "removed ${pkg_name} ${old_ver}" >> "$diff_file"
        has_changes=true
      fi
    done <<< "$removed"
  fi
done

# Print upgrade summary
if [[ "$should_snapshot" == true && "$has_changes" == false ]]; then
  echo "=== Upgrade Summary ==="
  echo "No global package changes."
elif [[ "$should_snapshot" == true && "$has_changes" == true ]]; then
  echo "=== Upgrade Summary ==="

  for node_dir in "$VERSIONS_DIR"/*/; do
    version=$(basename "$node_dir")
    diff_file="$TMPDIR_NVM_ALL/${version}_diff"

    if [[ ! -f "$diff_file" || ! -s "$diff_file" ]]; then
      echo "$version:"
      echo "  (no changes)"
      echo ""
      continue
    fi

    echo "$version:"

    # Calculate column widths for alignment
    max_pkg=0
    max_from=0
    while IFS=' ' read -r type pkg ver1 ver2; do
      (( ${#pkg} > max_pkg )) && max_pkg=${#pkg}
      case "$type" in
        updated) (( ${#ver1} > max_from )) && max_from=${#ver1} ;;
        added)   (( 5 > max_from )) && max_from=5 ;;  # "(new)" is 5 chars
        removed) (( ${#ver1} > max_from )) && max_from=${#ver1} ;;
      esac
    done < "$diff_file"

    # Print aligned rows
    while IFS=' ' read -r type pkg ver1 ver2; do
      case "$type" in
        updated) printf "  %-${max_pkg}s  %-${max_from}s → %s\n" "$pkg" "$ver1" "$ver2" ;;
        added)   printf "  %-${max_pkg}s  %-${max_from}s → %s\n" "$pkg" "(new)" "$ver1" ;;
        removed) printf "  %-${max_pkg}s  %-${max_from}s → %s\n" "$pkg" "$ver1" "(removed)" ;;
      esac
    done < "$diff_file"

    echo ""
  done
fi

if [[ $failures -gt 0 ]]; then
  echo "$failures version(s) failed."
  exit 1
fi
