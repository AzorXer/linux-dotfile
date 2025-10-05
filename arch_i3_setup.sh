#!/bin/bash

set -e

echo "------------------------------------------------------"
echo "   Installing Kitty + Thunar + feh + rofi + yay"
echo "------------------------------------------------------"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo bash i3wm-extras-setup.sh)"
  exit
fi

# Update system
echo "🔄 Updating system packages..."
pacman -Syu --noconfirm

# Install Kitty terminal
echo "🖥️ Installing Kitty terminal..."
pacman -S --noconfirm kitty

# Install Thunar + USB/CD support
echo "📁 Installing Thunar and USB/CD support..."
pacman -S --noconfirm thunar thunar-volman gvfs gvfs-mtp gvfs-afc gvfs-smb gvfs-nfs \
  gvfs-goa udiskie udisks2 ntfs-3g exfatprogs dosfstools

# Install feh (for wallpapers)
echo "🖼️ Installing feh..."
pacman -S --noconfirm feh

# Install rofi (app launcher)
echo "🚀 Installing rofi..."
pacman -S --noconfirm rofi

# Install yay (AUR helper)
echo "📦 Installing yay..."
if ! command -v yay &> /dev/null; then
  sudo -u "$SUDO_USER" bash <<'EOF'
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
EOF
else
  echo "✅ yay already installed"
fi

echo "------------------------------------------------------"
echo "✅ Installation Complete!"
echo "   Installed:"
echo "   - Kitty terminal"
echo "   - Thunar (with auto-mount)"
echo "   - feh (wallpapers)"
echo "   - rofi (launcher)"
echo "   - yay (AUR helper)"
echo "------------------------------------------------------"
