#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Setting up Ranger for Termux..."

# Install ranger
pkg install ranger python -y

# Create config directory
mkdir -p ~/.config/ranger

# Generate default config
ranger --copy-config=all 2>/dev/null

# Create custom rc.conf
cat > ~/.config/ranger/rc.conf << 'CONF'
set show_hidden true
set draw_borders both
set column_ratios 1,3,4
set colorscheme default
set preview_files true
set preview_directories true
set use_preview_script true
CONF

# Add ranger auto-start to .bashrc
if ! grep -q "# Ranger Auto-Start" ~/.bashrc; then
cat >> ~/.bashrc << 'BASH'

# Ranger Auto-Start
if [ -z "$RANGER_LEVEL" ] && [ -z "$TMUX" ]; then
    ranger
fi
BASH
fi

echo "✅ Ranger installed and configured!"
echo "✅ Auto-start added to .bashrc"
echo ""
echo "Launch now with: ranger"
echo "Or restart Termux for auto-start"
