{
  noctalia,
  ...
}@flakeInputs:
{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];

  options.eberman.enableDesktop = lib.mkEnableOption "Enable graphical programs";

  config = lib.mkIf config.eberman.enableDesktop {
    home.packages = with pkgs; [
      chromium
      diffoscope
      gdmap
      krita
      meld
    ];

    programs = {
      vscode.enable = true;

      ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
          gtk-titlebar-style = "tabs";
        };
      };

      noctalia = {
        enable = true;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = ''
        -- Fallback monitor rule
        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = "auto",
        })

        -- General appearance & decoration
        hl.config({
          general = {
            gaps_in = 5,
            gaps_out = 10,
          },
          decoration = {
            rounding = 12,
            blur = {
              enabled = true,
              xray = true,
              size = 3,
              passes = 2,
            },
          },
        })

        -- Autostart Noctalia Shell
        hl.on("hyprland.start", function()
          hl.exec_cmd("noctalia")
        end)

        local mainMod = "SUPER"
        local ipc = "noctalia msg "

        -- Core application shortcuts
        hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
        hl.bind(mainMod .. " + Q", hl.dsp.window.close())
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

        -- Noctalia Shell Integration
        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
        hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
        hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
        hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))

        -- Media & Hardware Keys
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))

        -- Directional Focus Movement
        hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
        hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
        hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
        hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
        hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
        hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

        -- Workspaces (1-9)
        for i = 1, 9 do
          hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
          hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
        end

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
      '';
    };

    home.activation.ensureHyprCustomConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.config/hypr
      if [ ! -e $HOME/.config/hypr/custom.lua ]; then
        $DRY_RUN_CMD touch $HOME/.config/hypr/custom.lua
      fi
    '';

    fonts.fontconfig = {
      defaultFonts.monospace = [ "CaskaydiaCove NF" ];
      enable = true;
    };
  };
}
