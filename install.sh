#!/usr/bin/env zsh

set -euo pipefail

BLUE="%F{blue}"
GREEN="%F{green}"
YELLOW="%F{yellow}"
RED="%F{red}"
NC="%f"

DOTFILES="${0:A:h}"
CONFIG_DIR="$HOME/.config"
BIN_DST="$HOME/.local/bin"

print -P "${BLUE}────────────────────────────────────────────${NC}"
print -P " ${BLUE}\"notreallyuri\"${NC} Dotfiles installer"
print
print -P " This script will:"
print -P "  ${GREEN}• Install configuration folders into ~/.config${NC}"
print -P "  ${GREEN}• Install executable scripts into ~/.local/bin${NC}"
print -P "  ${YELLOW}• Overwrite existing versions if they exist${NC}"
print -P "  ${RED}• NOT delete any user data files${NC}"
print
print -P " Source: $DOTFILES"
print -P " %B${RED}!!! REMEMBER TO BACKUP YOUR SETTINGS !!!%b"
print -P "${BLUE}────────────────────────────────────────────${NC}"

print -P " How would you like to install?"
print -P "  ${BLUE}1)${NC} Symlink (Syncs changes with repo)"
print -P "  ${BLUE}2)${NC} Copy (Standalone files)"
print -P "  ${BLUE}3)${NC} Exit"
print

read -r "?Select an option [1-3] (Default: 1): " choice
choice="${choice:-1}"

case "$choice" in
  1)
    MODE="link"
    INSTALL_CMD="ln -sf"
    ACTION_TEXT="Linking"
    print -P "${YELLOW}Selected: Symlinking${NC}"
    ;;
  2)
    MODE="copy"
    INSTALL_CMD="cp -Rp"
    ACTION_TEXT="Copying"
    print -P "${YELLOW}Selected: Copying${NC}"
    ;;
  3)
    print -P "${RED}Aborted.${NC}"
    exit 0
    ;;
  *)
    print -P "${RED}Invalid option selected. Aborting.${NC}"
    exit 1
    ;;
esac

mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DST"

print -P "\n${BLUE}●${NC} ${ACTION_TEXT} configuration folders..."

for folder in "$DOTFILES"/*(/); do
  name="${folder:t}"
  
  case "$name" in
    bin|scripts|.git|fonts) 
      continue
      ;;
    *) 
      print -P "  ${BLUE}→${NC} $name"
      rm -rf "$CONFIG_DIR/$name"
      ${=INSTALL_CMD} "$folder" "$CONFIG_DIR/$name"
      ;;
  esac
done

print -P "\n${BLUE}●${NC} ${ACTION_TEXT} executables to $BIN_DST..."

if [[ -d "$DOTFILES/bin" ]]; then
  for file in "$DOTFILES/bin"/*(N); do
    if [[ -f "$file" ]]; then
      name="${file:t}"
      chmod +x "$file"
      ${=INSTALL_CMD} "$file" "$BIN_DST/$name"
      print -P "  ${BLUE}→${NC} $name"
    fi
  done
else
  print -P "  ${RED}!${NC} Source bin directory not found."
fi

print -P "${GREEN}✔ Installation complete!${NC}"

print -P "${YELLOW}Checking Environment....${NC}"

local errors=0
local error_messages=()

if [[ ":$PATH:" != *":$BIN_DST:"* ]]; then
  error_messages+=("  ${RED}•${NC} $BIN_DST is not in your PATH.")
  ((errors++))
fi

if ! command -v lua >/dev/null 2>&1; then
  error_messages+=("  ${RED}•${NC} 'lua' is not installed. Script logic may fail.")
  ((errors++))
fi

if ! command -v fastfetch >/dev/null 2>&1; then
  error_messages+=("  ${RED}•${NC} 'fastfetch' is not installed. nofetch will fail.")
  ((errors++))
fi

if (( errors == 0 )); then
  print -P "  ${GREEN}✔${NC} All dependencies and paths are correct. No problems found."
else
  print -P "  ${RED}Found $errors environment issue(s):${NC}"
  for msg in $error_messages; do
    print -P "$msg"
  done
fi
