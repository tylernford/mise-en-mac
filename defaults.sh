#!/usr/bin/env bash
# Apply opinionated macOS system preferences via `defaults write`.
# Safe to re-run; settings just get reasserted.
set -euo pipefail

# Close System Settings so it doesn't override our writes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false

# --- Mission Control ---
defaults write com.apple.dock mru-spaces -bool false

# --- Screenshots ---
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Save / open panels ---
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# --- Safari ---
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# --- Trackpad ---
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Keyboard ---
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- Text substitution (off — breaks code paste) ---
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# --- Security ---
# Skip "are you sure you want to open this?" prompt for downloaded apps.
# Gatekeeper still vets signed/notarized apps.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Apply changes by restarting affected services
killall Finder Dock SystemUIServer 2>/dev/null || true

echo "Done. Some changes (e.g. key repeat) require a logout/restart to take full effect."
