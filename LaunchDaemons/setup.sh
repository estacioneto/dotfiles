#!/bin/bash -e

current_dir=$(dirname -- "$(readlink -f "$0")")
# Copy the plist file to /Library/LaunchDaemons
echo "💿 Copying the plist file to /Library/LaunchDaemons"
sudo cp "$current_dir/com.$USER.remapkeys.plist" /Library/LaunchDaemons/com."$USER".remapkeys.plist &&
  echo "✅ Copied the plist file to /Library/LaunchDaemons" ||
  echo "❌ Failed to copy the plist file to /Library/LaunchDaemons" && exit 1

echo

sudo chown root:wheel /Library/LaunchDaemons/com."$USER".remapkeys.plist
sudo chmod 644 /Library/LaunchDaemons/com."$USER".remapkeys.plist

echo "🚀 To launch the daemon, run the following command copied to clipboard:"
echo "sudo launchctl load -w /Library/LaunchDaemons/com."$USER".remapkeys.plist"

echo "sudo launchctl load -w /Library/LaunchDaemons/com."$USER".remapkeys.plist" | pbcopy
