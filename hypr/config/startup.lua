local startup_cmds = {
  "dbus-update-activation-environment --systemd --all",
  "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH XDG_DATA_DIRS HYPRLAND_INSTANCE_SIGNATURE",
  "gnome-keyring-daemon --start --components=secrets",
  "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",

  "xrandr --output DP-1 --primary",
  "hyprctl setcursor Bibata-Original-Classic 24",
  "noctalia",
  "mpris-proxy",

  "[workspace special:comm silent] discord",
  "[workspace special:music silent] cider --ozone-platform=x11 %U",
  "[workspace special:browser silent] helium-browser",
}

hl.on("hyprland.start", function()
  for _, cmd in ipairs(startup_cmds) do
    hl.exec_cmd(cmd)
  end
end)
