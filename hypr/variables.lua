local home = os.getenv("HOME")

local M = {}

M.apps = {
  terminal = "ghostty",
  browser = "zen-browser",
  filemgr = "yazi",
  menu = "rofi -show drun",
  editor = "nvim",
  colorpicker = "hyprpicker",
  lock = "hyprlock",
  calc = "rofi -show calc",
  ipc = "noctalia msg ",
  noshot = home .. "/.config/noshot/noshot.lua",
}

M.kb = {
  move_win = "SUPER + SHIFT",
  go_to = "SUPER",
  resize = "SUPER + ALT",

  terminal = "SUPER + Q",
  filemgr = "SUPER + E",
  menu = "SUPER + R",
  copy_color = "SUPER + SHIFT + C",
  lock = "SUPER + P",
  calc = "SUPER + T",

  float_toggle = "SUPER + H",
  fullscreen = "SUPER + F",
  close = "SUPER + C",
  split = "SUPER + J",

  shot_region = "Print",
  shot_screen = "SUPER + Print",
  shot_edit = "SHIFT + Print",
  shot_window = "ALT + Print",
  shot_all = "CTRL + Print",
  shot_ocr = "SUPER + SHIFT + S",
  shot_search = "SUPER + SHIFT + A",

  record = "SUPER + SHIFT + R",
  record_audio = "SUPER + SHIFT + ALT + R",
  record_pause = "SUPER + ALT + R",
  replay = "SUPER + SHIFT + F12",
  replay_save = "SUPER + F12",

  control_center = "SUPER + S",
  settings = "SUPER + comma",
  wallpaper = "SUPER + W",

  games = "SUPER + G",
  comm = "SUPER + D",
  music = "SUPER + M",
  scratch = "SUPER + apostrophe",

  move_games = "SUPER + SHIFT + G",
  move_comm = "SUPER + SHIFT + D",
  move_music = "SUPER + SHIFT + M",

  move_mouse = "SUPER + mouse:272",
  resize_mouse = "SUPER + mouse:273",
}

return M
