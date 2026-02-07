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
print -P " ${BLUE}\"notreallyuri\"${NC} Dotfiles Uninstaller"
print
print -P " This script will remove:"
print -P "  ${RED}• Symlinks${NC} pointing to this repo"
print -P "  ${RED}• Copied folders/files${NC} matching repo names"
print -P " ${YELLOW}Location:${NC} $DOTFILES"
print -P "${BLUE}────────────────────────────────────────────${NC}"

print -P "${BLUE}Scanning for installed components...${NC}"

items_to_remove=()

for folder in "$DOTFILES"/*(/); do
  name="${folder:t}"
  case "$name" in bin | scripts | .git | fonts) continue ;; esac

  target="$CONFIG_DIR/$name"
  if [[ -e "$target" ]]; then
    items_to_remove+=("$target")
  fi
done

if [[ -d "$DOTFILES/bin" ]]; then
  for file in "$DOTFILES/bin"/*(N); do
    name="${file:t}"
    target="$BIN_DST/$name"
    if [[ -e "$target" ]]; then
      items_to_remove+=("$target")
    fi
  done
fi

if ((${#items_to_remove} == 0)); then
  print -P "  ${GREEN}✔${NC} No matching installations found in .config or bin."
  exit 0
fi

print -P " Found ${YELLOW}${#items_to_remove}${NC} items to remove:"
for item in $items_to_remove; do
  type_label="[File/Folder]"
  [[ -L "$item" ]] && type_label="[Symlink]"
  print -P "  ${RED}•${NC} ${item/$HOME/\~} ${BLUE}$type_label${NC}"
done

print
read -r "?Are you sure you want to delete these? This cannot be undone. [y/N] " reply
[[ "$reply" != [yY] ]] && print -P "${RED}Aborted.${NC}" && exit 0

print -P "\n${RED}●${NC} Removing items..."

for item in $items_to_remove; do
  print -P "  ${RED}×${NC} Removing ${item:t}..."
  rm -rf "$item"
done

print -P "\n${GREEN}✔ Cleanup complete.${NC}"
