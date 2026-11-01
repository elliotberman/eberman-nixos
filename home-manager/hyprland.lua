hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
end)

-- Fallback monitor rule
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

-- General appearance & decoration
hl.config({
  general = {
    border_size = 3,
    col = {
      active_border = "0xff3584e4",
    },
    gaps_in = 0,
    gaps_out = 0,
    layout = "master",
    resize_on_border = true,
  },
  decoration = {
    rounding = 12,
    blur = {
      enabled = true,
      xray = true,
      size = 3,
      passes = 2,
   },
    dim_inactive = true,
    dim_strength = 0.02,
    shadow = {
      enabled = true,
    },
  },
})

local mainMod = "SUPER"
local noctalia = "noctalia msg "

-- Core application shortcuts
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("chromium"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Noctalia Shell Integration
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"))
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(noctalia .. "panel-toggle kenn/keybind-cheatsheet:cheatsheet"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(noctalia .. "window-switcher hold"))

-- Media & Hardware Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctalia .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctalia .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noctalia .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctalia .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctalia .. "brightness-down"))

-- Directional Focus Movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces (1-9)
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + CONTROL + left",  hl.dsp.focus({ workspace = "e-1"; }))
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.focus({ workspace = "e+1"; }))

-- Noctalia Layer & Window Rules
hl.layer_rule({
  name = "noctalia",
  match = {
  namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

hl.window_rule({
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  size = { 1080, 920 },
})

-- Safely load imperative local overrides if present
local custom_file = os.getenv("HOME") .. "/.config/hypr/custom.lua"
local f = io.open(custom_file, "r")
if f ~= nil then
  io.close(f)
  dofile(custom_file)
end