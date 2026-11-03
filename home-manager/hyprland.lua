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
  misc = {
    focus_on_activate = true,
  },
  input = {
    follow_mouse = 0,
    touchpad = {
      natural_scroll = true,
    },
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

-- Colors rendered by Noctalia's hyprland template; absent until its first run
local ok, noctalia_theme = pcall(require, "noctalia")
if ok then noctalia_theme.apply_theme() end
pcall(require, "noctalia-groupbar")
-- Without gradients only the thin indicator strip is drawn; the tab body shows the wallpaper
hl.config({
  group = {
    groupbar = {
      gradients = true,
      gaps_in = 0,
      gaps_out = 0,
      keep_upper_gap = false,
    },
  },
})

local mainMod = "SUPER"
local noctalia = "noctalia msg "

-- 1. Applications
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("chromium"), { description = "Launch browser" })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("ghostty"), { description = "Launch terminal" })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("code"), { description = "Launch VS Code" })
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"), { description = "Toggle app launcher" })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"), { description = "Launch calculator" })

-- 2. Windows
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
-- A window that floats keeps its tiled spot but shrinks to 90%.
hl.bind(mainMod .. " + V", function()
  local w = hl.get_active_window()
  local tiled = w and not w.floating
  local at, size = w and w.at, w and w.size
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  if tiled then
    local nw, nh = math.floor(size.x * 0.9), math.floor(size.y * 0.9)
    local addr = "address:" .. w.address
    hl.dispatch(hl.dsp.window.resize({ x = nw, y = nh, window = addr }))
    hl.dispatch(hl.dsp.window.move({ x = at.x + (size.x - nw) // 2, y = at.y + (size.y - nh) // 2, window = addr }))
  end
end, { description = "Toggle floating" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle group (tabs)" })
hl.bind("ALT + Tab", hl.dsp.exec_cmd(noctalia .. "window-switcher hold"), { description = "Window switcher" })
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(noctalia .. "window-switcher hold reverse"), { description = "Window switcher (reverse)" })
-- Swap with the neighbour in dir; at the workspace edge, trade places with the window on the
-- adjacent monitor's workspace, or just move there if that monitor is empty. Nothing happens
-- past the last monitor.
local function monitor_toward(from, dir)
  local horiz = dir == "left" or dir == "right"
  local best, best_gap
  for _, m in ipairs(hl.get_monitors()) do
    if m.id ~= from.id then
      local gap, overlap
      if horiz then
        gap = dir == "right" and m.x - (from.x + from.width) or from.x - (m.x + m.width)
        overlap = m.y < from.y + from.height and from.y < m.y + m.height
      else
        gap = dir == "down" and m.y - (from.y + from.height) or from.y - (m.y + m.height)
        overlap = m.x < from.x + from.width and from.x < m.x + m.width
      end
      if overlap and gap >= 0 and (not best_gap or gap < best_gap) then
        best, best_gap = m, gap
      end
    end
  end
  return best
end

local function swap(dir)
  local w = hl.get_active_window()
  if not w then return end
  local wid = w.workspace.id
  -- Probe with focus, since swap alone can't tell us whether it hit an edge.
  hl.dispatch(hl.dsp.focus({ direction = dir }))
  local n = hl.get_active_window()
  hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
  if not n or n.address == w.address then
    local m = monitor_toward(w.monitor, dir)
    if not m then return end
    hl.dispatch(hl.dsp.window.move({
      workspace = desktops.ws_id(desktops.current(), m),
      follow = false,
      window = "address:" .. w.address,
    }))
    hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
    return
  end
  local nid = n.workspace.id
  if nid == wid then
    hl.dispatch(hl.dsp.window.swap({ direction = dir }))
  else
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(nid), follow = false, window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(wid), follow = false, window = "address:" .. n.address }))
    hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
  end
end

-- j/k mirror left/right
local function bind_keys(mods, keys, action, opts)
  for _, k in ipairs(keys) do hl.bind(mods .. " + " .. k, action, opts) end
end
local left, right, up, down = { "left", "J" }, { "right", "K" }, { "up" }, { "down" }

bind_keys(mainMod, left, function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end, { description = "Focus window left" })
bind_keys(mainMod, right, function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end, { description = "Focus window right" })
bind_keys(mainMod, up, function() hl.dispatch(hl.dsp.focus({ direction = "up" })) end, { description = "Focus window up" })
bind_keys(mainMod, down, function() hl.dispatch(hl.dsp.focus({ direction = "down" })) end, { description = "Focus window down" })
bind_keys("ALT", left, function() swap("left") end, { description = "Swap window left" })
bind_keys("ALT", right, function() swap("right") end, { description = "Swap window right" })
bind_keys("ALT", up, function() swap("up") end, { description = "Swap window up" })
bind_keys("ALT", down, function() swap("down") end, { description = "Swap window down" })
bind_keys(mainMod .. " + SHIFT", left, hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "Shrink window width" })
bind_keys(mainMod .. " + SHIFT", right, hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true, description = "Grow window width" })
bind_keys(mainMod .. " + SHIFT", up, hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true, description = "Shrink window height" })
bind_keys(mainMod .. " + SHIFT", down, hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true, description = "Grow window height" })
-- Mouse: drag to move/reorder, right-drag to resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window (move)" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Drag window (resize)" })

-- 3. Desktops
-- A desktop spans every monitor: desktop N is one workspace per monitor, all switched
-- together. Workspace id = N * 100 + the monitor's slot. Hyprland slides by comparing ids,
-- and named workspaces get ever-more-negative ids, which made the animation run backwards.
-- Machine-specific config fills desktops.slots with { match = <description substring>, slot = n }.
desktops = { slots = {} }

local laptop = "eDP-1"

local function slot_of(mon)
  if mon.name == laptop then
    return 1
  end
  for _, s in ipairs(desktops.slots) do
    if mon.description:find(s.match, 1, true) then
      return s.slot
    end
  end
  return 50 + mon.id
end

local function ws_id(desk, mon)
  return tostring(desk * 100 + slot_of(mon))
end

-- Ids below 100 are Hyprland's default workspaces, not desktops.
local function parse(ws)
  if ws.special or ws.id < 100 then
    return nil
  end
  return ws.id // 100
end

local cur = 1
local switching = false

local function switch(n)
  if switching then
    return
  end
  switching = true
  local origin = hl.get_active_monitor()
  -- A new workspace is created on the focused monitor, so visit each monitor in turn.
  for _, m in ipairs(hl.get_monitors()) do
    hl.dispatch(hl.dsp.focus({ monitor = m.name }))
    hl.dispatch(hl.dsp.focus({ workspace = ws_id(n, m), on_current_monitor = true }))
  end
  if origin then
    hl.dispatch(hl.dsp.focus({ monitor = origin.name }))
  end
  cur = n
  switching = false
end

-- Occupied desktops, ascending, from the windows that live on desktop workspaces.
local function occupied()
  local seen, list = {}, {}
  for _, w in ipairs(hl.get_windows()) do
    local desk = w.workspace and parse(w.workspace)
    if desk and not seen[desk] then
      seen[desk] = true
      list[#list + 1] = desk
    end
  end
  table.sort(list)
  return list, seen
end

-- GNOME-style dynamic desktops: step over empty ones, allow one empty desktop past the last
-- occupied one, and never go below 1.
local function target(dir)
  local list, seen = occupied()
  if dir < 0 then
    for i = #list, 1, -1 do
      if list[i] < cur then
        return list[i]
      end
    end
    return nil
  end
  for _, d in ipairs(list) do
    if d > cur then
      return d
    end
  end
  if seen[cur] then
    return cur + 1
  end
  return nil
end

local function go(dir)
  local t = target(dir)
  if t then
    switch(t)
  end
end

local function carry_to(n)
  local w = hl.get_active_window()
  if not w then
    return
  end
  -- Switch first so the destination workspace exists on this monitor, then move the window in.
  switch(n)
  hl.dispatch(hl.dsp.window.move({
    workspace = ws_id(n, hl.get_active_monitor()),
    follow = false,
    window = "address:" .. w.address,
  }))
  hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
end

local function carry(dir)
  local t = target(dir)
  if t then
    carry_to(t)
  end
end

bind_keys(mainMod .. " + CONTROL", left, function() go(-1) end, { description = "Previous desktop" })
bind_keys(mainMod .. " + CONTROL", right, function() go(1) end, { description = "Next desktop (or a new one)" })
bind_keys(mainMod .. " + CONTROL + ALT", left, function() carry(-1) end, { description = "Move window to previous desktop" })
bind_keys(mainMod .. " + CONTROL + ALT", right, function() carry(1) end, { description = "Move window to next desktop" })

for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, function() switch(i) end, { description = "Go to desktop " .. i })
  hl.bind(mainMod .. " + SHIFT + " .. i, function() carry_to(i) end, { description = "Move window to desktop " .. i })
end

-- Something else changed a workspace (a click in noctalia, the mouse): bring the rest along.
hl.on("workspace.active", function(ws)
  if switching or ws.special then
    return
  end
  local desk = parse(ws)
  if desk and desk ~= cur then
    switch(desk)
  end
end)

hl.on("hyprland.start", function() switch(1) end)

-- For machine-specific config (monitors.lua) that must place windows on desktops.
desktops.ws_id, desktops.parse, desktops.switch = ws_id, parse, switch
desktops.current = function() return cur end

-- 4. Noctalia Shell
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center"), { description = "Toggle control center" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center calendar"), { description = "Toggle calendar" })
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"), { description = "Toggle session menu (logout/power)" })
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(noctalia .. "panel-toggle kenn/keybind-cheatsheet:cheatsheet"), { description = "Show keybind cheatsheet" })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(noctalia .. "session lock"), { description = "Lock session" })

-- 5. Screenshots
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(noctalia ..  "screenshot-fullscreen pick"), { description = "Screenshot: fullscreen"})
hl.bind("Print", hl.dsp.exec_cmd(noctalia .. "screenshot-region"), { description = "Screenshot: region" })

-- 6. Media & Hardware Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctalia .. "volume-up"), { description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctalia .. "volume-down"), { description = "Volume down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noctalia .. "volume-mute"), { description = "Mute volume" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctalia .. "brightness-up"), { description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctalia .. "brightness-down"), { description = "Brightness down" })

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

hl.window_rule({
  match = { class = "^org\\.gnome\\.Calculator$" },
  float = true,
  size = { 420, 620 },
  -- window_w/h hold the client's request here, not the rule's size, so repeat the size literally.
  move = {
    "max(0, min(monitor_w - 420, cursor_x - 210))",
    "max(0, min(monitor_h - 620, cursor_y - 310))",
  },
})

-- Safely load imperative local overrides if present
local custom_file = os.getenv("HOME") .. "/.config/hypr/custom.lua"
local f = io.open(custom_file, "r")
if f ~= nil then
  io.close(f)
  dofile(custom_file)
end