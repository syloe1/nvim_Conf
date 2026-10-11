#!/bin/bash
set -e

echo "-- NeoVim 0.9.1 or above not found, installing latest for you."

cd "$(dirname $0)/.."

install_snap() {
    if ! which apt >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y || true
        sudo apt install -y snapd || true
    elif ! which zypper >/dev/null 2>&1; then
        sudo zypper in --no-confirm snapd || true
    elif ! which dnf >/dev/null 2>&1; then
        sudo dnf install -y epel-release || true
        sudo dnf upgrade || true
        sudo dnf install -y snapd || true
    elif ! which yum >/dev/null 2>&1; then
        sudo yum install -y epel-release || true
        sudo yum install -y snapd || true
    fi
    sudo systemctl enable --now snapd || true
}

if which pacman >/dev/null 2>&1; then
  echo "-- Installing latest nvim with pacman..."
  pacman -S --noconfirm neovim
else
  echo "-- Trying installing latest nvim from snap..."
  if ! which snap >/dev/null 2>&1; then
      echo "-- Snap not found, try installing for you..."
      install_snap
  fi
  sudo snap install nvim
fi
