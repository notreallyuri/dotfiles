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
print -P "  ${GREEN}• Symlink config folders into ~/.config${NC}"
print -P "  ${GREEN}• Symlink executable scripts into ~/.local/bin${NC}"
print -P "  ${YELLOW}• Overwrite existing symlinks if they exist${NC}"
print -P "  ${RED}• NOT delete any user files${NC}"
print
print -P " Repo will be linked from its current location."
print -P "${BLUE}────────────────────────────────────────────${NC}"

read -r "?Continue with installation? [y/N]" reply
[[ "$reply" != [yY] ]] && echo "Aborted." && exit 0

mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DST"

print -P "\n${BLUE}●${NC} Linking configuration folders..."

for folder in "$DOTFILES"/*(/); do
  name="${folder:t}"
  
  case "$name" in
    bin|scripts|.git) 
      continue
      ;;
    *) 
      print -P "  ${BLUE}→${NC} $name"
      ln -sf "$folder" "$CONFIG_DIR/$name"
      ;;
  esac
done

print -P "\n${BLUE}●${NC} Linking executables to $BIN_DST..."

if [[ -d "$DOTFILES/bin" ]]; then
  for file in "$DOTFILES/bin"/*(N); do
    if [[ -f "$file" ]]; then
      name="${file:t}"
      chmod +x "$file"
      ln -sf "$file" "$BIN_DST/$name"
      print -P "  ${BLUE}→${NC} $name"
    fi
  done
else
  print -P "  ${RED}!${NC} Source bin directory not found."
fi

print -P "${GREEN}✔ Installation complete!${NC}"

print -P "${YELLOW}Checking Environment....${NC}"

local errors=0
local error_message=()

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
