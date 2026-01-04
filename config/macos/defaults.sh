#!/bin/bash
# ==============================================================================
#   macOS Zen State (v3.5)
#  System Settings (LUDICROUS SPEED + NETWORK + MENU BAR + TEXT)
# ==============================================================================

# Close System Settings to prevent it from overwriting our changes
osascript -e 'tell application "System Settings" to quit'
echo "🚀 Starting macOS configuration (Extreme Mode)..."

# ==============================================================================
# 0. NETWORK PRIORITY
# ==============================================================================
echo "🛜  Optimizing Network (Ethernet > Wi-Fi)..."

# Prioritize Ethernet over Wi-Fi
sudo networksetup -ordernetworkservices "Ethernet" "Wi-Fi" "Thunderbolt Bridge" 2>/dev/null
echo "   -> Network Service Order updated."

# ==============================================================================
# 1. INPUT DEVICES (KEYBOARD & TRACKPAD)
# ==============================================================================
echo "⌨️  Applying 'Ludicrous Speed' Keyboard settings..."

# KEYBOARD SPEED (Undocumented Limits)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 4

# CRITICAL: Disable "Press and Hold" for accents so keys repeat immediately
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable annoying auto-corrections (Quotes & Dashes)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set specific Smart Quote characters (Even if substitution is disabled)
defaults write NSGlobalDomain KB_DoubleQuoteOption -string "\U201cabc\U201d"
defaults write NSGlobalDomain KB_SingleQuoteOption -string "\U2018abc\U2019"
defaults write NSGlobalDomain NSUserQuotesArray -array \
    '"\U201c"' \
    '"\U201d"' \
    '"\U2018"' \
    '"\U2019"'

# Text Correction Settings
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true
# Enable "Automatic by Language" for Spelling
defaults write NSGlobalDomain KB_SpellingLanguage -dict KB_SpellingLanguageIsAutomatic -bool true
# KEEP "Add full stop with double-space"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

# TRACKPAD GESTURES & SPEED
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2

defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "Natural" Scrolling (Standard Scroll Direction)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# ==============================================================================
# 2. UI/UX & FINDER
# ==============================================================================
echo "🖥  Configuring Finder & Window behaviors..."

# Dark Mode (Overrides Auto Mode)
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Save Panels & Printing
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain NSNavPanelExpandedSizeForSaveMode -string "{880, 448}"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Screenshots
mkdir -p "${HOME}/.screenshots"
defaults write com.apple.screencapture location -string "${HOME}/.screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Desktop Cleanup
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# Finder Navigation & View
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# View Style: Column
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder FXPreferredSearchViewStyle -string "clmv"
defaults write com.apple.finder _FXEnableColumnAutoSizing -bool true

# Grouping & Sorting
defaults write com.apple.finder FXPreferredGroupBy -string "Date Modified"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search Scope: Current Folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXLastSearchScope -string "SCcf"

# Finder Sidebar & Toolbar Cleanup
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder SidebarTagsSctionDisclosedState -bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Show all extensions & hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Advanced View Settings (Arrange By & Font Size)
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:ArrangeBy kipl" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:FontSize 14" ~/Library/Preferences/com.apple.finder.plist

# Search Window State
defaults write com.apple.finder SearchViewSettings -dict-add WindowState '{
    ContainerShowSidebar = 1;
    ShowSidebar = 1;
    ShowStatusBar = 1;
    ShowToolbar = 1;
}'

# Avoid creating .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ==============================================================================
# 3. DOCK & SAFARI
# ==============================================================================
echo "⚓️  Setting up Dock & Safari..."

# Change Dock orientation to Left
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock pinning -string end

# Change Minimize effect to Scale (Snappier than Genie)
defaults write com.apple.dock mineffect -string "scale"

# Set Desktop Widgets to Monochrome
defaults write com.apple.WindowManagerWidgetStyle -int 2

# Hot Corners: Bottom Right = Desktop (Modifier: Cmd)
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 1048576

# Safari Developer Mode
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# ==============================================================================
# 4. SYSTEM & SECURITY
# ==============================================================================
echo "🔒  Hardening Guest User settings..."

GUEST_STATUS=$(defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null)
if [ "$GUEST_STATUS" -ne 1 ]; then
    echo "   -> Enabling Guest User..."
    sudo sysadminctl -guestAccount on
fi
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

# Display and Login Security
sudo pmset -a displaysleep 20
# Login: Show "Name & Password" fields instead of "List of Users" (10:43)
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# ==============================================================================
# 4.1 MENU BAR CUSTOMIZATION
# ==============================================================================
echo "🍷  Customizing Menu Bar..."

# Show Battery Percentage in Menu Bar
defaults write com.apple.controlcenter.plist BatteryShowPercentage -bool true

# Show Bluetooth in Menu Bar (Active)
defaults write com.apple.controlcenter.plist Bluetooth -int 18

# Hide Spotlight Icon from Menu Bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# ==============================================================================
# 5. APPS (ALTTAB)
# ==============================================================================
echo "⌘  Configuring AltTab..."

defaults write com.lwouis.alt-tab-macos holdShortcut -string "\U2318"
defaults write com.lwouis.alt-tab-macos menubarIcon -int 2
defaults write com.lwouis.alt-tab-macos mouseHoverEnabled -bool true
defaults write com.lwouis.alt-tab-macos startAtLogin -bool true
defaults write com.lwouis.alt-tab-macos appearanceSize -int 0
defaults write com.lwouis.alt-tab-macos updatePolicy -int 1

# ==============================================================================
# 6. MANUAL STEPS (UNSCRIPTABLE SETTINGS)
# ==============================================================================
echo "👇 Opening Settings panes for manual items..."

# Spotlight Indexing Categories (Cannot be scripted safely)
open "x-apple.systempreferences:com.apple.Spotlight-Settings"

# Displays (For True Tone, Night Shift, Auto-Brightness)
open "x-apple.systempreferences:com.apple.Displays-Settings"

# ==============================================================================
# 7. RESTART SERVICES
# ==============================================================================
echo "♻️   Restarting Finder, Dock, Control Center, and UI Server..."
for app in "Dock" "Finder" "Safari" "SystemUIServer" "ControlCenter"; do
    killall "${app}" > /dev/null 2>&1
done

echo "✅  Extreme settings applied."
echo "⚠️  CRITICAL: Restart required."
