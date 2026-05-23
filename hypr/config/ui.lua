local colors = {
  active = "rgba(73,187,244,0.8)",
  inactive = "rgba(0,0,0,0)",
  shadow = "rgba(1a1a1aee)",
}

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    ["col.active_border"] = colors.active,
    ["col.inactive_border"] = colors.inactive,
    layout = "scrolling",
    resize_on_border = true,
    allow_tearing = false,
  },

  scrolling = {
    column_width = 0.95,
    focus_fit_method = 0,
    direction = "down",
  },

  decoration = {
    rounding = 0,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.97,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = colors.shadow,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      vibrancy = 0.1696,
    },
  },

  hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1.00 }, { 0.32, 1.00 } } }),
  hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1.00 } } }),
  hl.curve("almostLinear", { type = "bezier", points = { { 0.50, 0.50 }, { 0.75, 1.00 } } }),
  hl.curve("quick", { type = "bezier", points = { { 0.15, 0.00 }, { 0.10, 1.00 } } }),
  hl.curve("linear", { type = "bezier", points = { { 0.00, 0.00 }, { 1.00, 1.00 } } }),

  hl.animation({ leaf = "global", enabled = true, speed = 10.0, bezier = "linear" }),
  hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" }),
  hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" }),
  hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.10,
    bezier = "easeOutQuint",
    style = "popin 87%",
  }),
  hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.49,
    bezier = "linear",
    style = "popin 87%",
  }),
  hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" }),
  hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" }),
  hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" }),
  hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" }),
  hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.00,
    bezier = "easeOutQuint",
    style = "fade",
  }),
  hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 1.50,
    bezier = "linear",
    style = "fade",
  }),
  hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" }),
  hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" }),

  hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3.00,
    bezier = "easeOutQuint",
    style = "slide",
  }),
  hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 3.00,
    bezier = "easeOutQuint",
    style = "slide",
  }),
  hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 3.00,
    bezier = "easeOutQuint",
    style = "slide",
  }),
})
