{
  chromium,
  hyprland,
  jq,
  writeShellApplication,
}:
writeShellApplication {
  name = "xdg-browser-dispatch";
  runtimeInputs = [
    chromium
    hyprland
    jq
  ];
  # Chromium's singleton hands the URL to its last-active window, so focusing the
  # target first makes the new tab land there. No match: force a new window, else
  # the singleton opens a tab in a window on another workspace.
  text = ''
    url=$1
    ws=$(hyprctl activewindow -j | jq -r '.workspace.id // empty')
    if [[ -n $ws ]]; then
      addr=$(hyprctl clients -j | jq -r --argjson ws "$ws" '
        [.[] | select((.class | startswith("chromium")) and .workspace.id == $ws)]
        | sort_by(.focusHistoryID) | .[0].address // empty')
      if [[ -n $addr ]]; then
        hyprctl dispatch "hl.dsp.focus({ window = 'address:$addr' })" >/dev/null
        exec chromium "$url"
      fi
    fi
    exec chromium --new-window "$url"
  '';
}
