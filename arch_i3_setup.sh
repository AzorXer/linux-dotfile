#!/bin/bash

# -------------------------
# Update system
# -------------------------
sudo pacman -Syu --noconfirm

# Install i3 and basic tools
sudo pacman -S --noconfirm \
    i3-wm \
    i3status \
    i3lock \
    base-devel \
    git \
    firefox \
    alsa-utils \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    pavucontrol \
    thunar \
    gvfs \
    gvfs-mtp \
    gvfs-gphoto2 \
    udisk2 \
    xorg-server \
    xorg-xinit \
    kitty \
    rofi \
    networkmanager \
    network-manager-applet \
    brightnessctl \
    feh

# Enable NetworkManager service
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Enable PipeWire services
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable pipewire-media-session

# Install yay (AUR helper)
if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

# -------------------------
# Setup modular i3 config (user-editable)
# -------------------------
CONFIG_DIR="$HOME/.config/i3"
mkdir -p "$CONFIG_DIR"

# Main config
cat > "$CONFIG_DIR/config" << 'EOF'
# -------------------------
# i3 Main Config
# -------------------------
set $mod Mod4

# Include keybindings, apps, status bar
include keybindings.conf
include apps.conf
include statusbar.conf
EOF

# Keybindings
cat > "$CONFIG_DIR/keybindings.conf" << 'EOF'
# -------------------------
# Keybindings
# -------------------------
# Terminal
set $term kitty
bindsym $mod+Return exec $term

# App launcher
bindsym $mod+d exec rofi -show drun

# File manager
bindsym $mod+e exec thunar

# Reload / Restart / Exit
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# Volume Control (Universal)
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness Control (Universal)
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-
EOF

# Autostart apps
cat > "$CONFIG_DIR/apps.conf" << 'EOF'
# -------------------------
# Autostart Programs
# -------------------------
exec --no-startup-id nm-applet
exec --no-startup-id pipewire
exec --no-startup-id pipewire-pulse
exec --no-startup-id pipewire-media-session
exec --no-startup-id pavucontrol
EOF

# Status bar default
cat > "$CONFIG_DIR/statusbar.conf" << 'EOF'
# -------------------------
# Optional Status Bar
# -------------------------
# Default i3status is included with i3
EOF

# Ensure user owns the config
chown -R $USER:$USER "$CONFIG_DIR"

# -------------------------
# Ask for Polybar installation
# -------------------------
read -p "Do you want to install Polybar (y/n)? " install_polybar
if [[ "$install_polybar" =~ ^[Yy]$ ]]; then
    yay -S --noconfirm polybar

    # Update statusbar.conf to launch Polybar
    cat > "$CONFIG_DIR/statusbar.conf" << 'EOF'
# -------------------------
# Polybar Status Bar
# -------------------------
exec_always --no-startup-id polybar mybar
EOF

    # Setup example Polybar config
    POLYBAR_DIR="$HOME/.config/polybar"
    mkdir -p "$POLYBAR_DIR"

    cat > "$POLYBAR_DIR/config" << 'EOF'
[bar/mybar]
width = 100%
height = 28
background = #222222
foreground = #ffffff
font-0 = monospace:size=10
modules-left = i3
modules-center = date
modules-right = pulseaudio

[module/i3]
type = internal/i3

[module/date]
type = internal/date
interval = 5
date = %Y-%m-%d
time = %H:%M:%S

[module/pulseaudio]
type = internal/pulseaudio
format = <volume>% <status>
EOF

    echo "✅ Polybar installed with example config."
else
    echo "✅ Skipped Polybar installation. Default i3status will be used."
fi

# -------------------------
# Ask for wallpaper
# -------------------------
read -p "Do you want to set a wallpaper using feh? (y/n) " set_wallpaper
if [[ "$set_wallpaper" =~ ^[Yy]$ ]]; then
    read -p "Enter full path to your wallpaper image: " wallpaper_path
    if [[ -f "$wallpaper_path" ]]; then
        # Add wallpaper command to apps.conf
        echo "exec --no-startup-id feh --bg-scale \"$wallpaper_path\"" >> "$CONFIG_DIR/apps.conf"
        echo "✅ Wallpaper set and will load automatically in i3."
    else
        echo "❌ File not found. Skipping wallpaper setup."
    fi
else
    echo "✅ Skipped wallpaper setup."
fi

echo "✅ Full i3 setup complete! All configs are user-editable in $CONFIG_DIR."
echo "Use Super+Enter for Kitty, Super+d for Rofi, Super+e for Thunar."
echo "Volume and brightness keys should work universally."
echo "Autostart apps: nm-applet, PipeWire, pavucontrol."
echo "Optional Polybar installed if selected."