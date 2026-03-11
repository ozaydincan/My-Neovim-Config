#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

FONT="FiraCode"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT}.zip"
FONT_DIR="$HOME/.local/share/fonts"

echo "Updating packages and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y unzip fontconfig wget

echo "Creating local fonts directory..."
mkdir -p "$FONT_DIR"

echo "Downloading patched $FONT Nerd Font..."
wget -qO "/tmp/${FONT}.zip" "$URL"

echo "Extracting fonts..."
unzip -qo "/tmp/${FONT}.zip" -d "$FONT_DIR"

echo "Cleaning up..."
rm "/tmp/${FONT}.zip"

echo "Rebuilding font cache..."
fc-cache -fv

echo "Success! The fully patched FiraCode Nerd Font is now installed."

