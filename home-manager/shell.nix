{ pkgs, lib, ... }:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        c.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
        package.disabled = true;
        rust.disabled = true;
        shell.disabled = false;
        shell.zsh_indicator = "";
        username.disabled = true;

        direnv = {
          disabled = false;
          symbol = "📁";
          format = "[$symbol$loaded$allowed]($style)";
          allowed_msg = "";
          loaded_msg = "";
        };

        nix_shell = {
          symbol = "❄️";
          format = "via [$symbol $name]($style) ";
        };
      };
    };

    bash.enable = true;
    zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "tmux"
        ];
      };

      shellAliases = {
        gcane = "git commit --amend --no-edit";
        gcod = "git checkout --detach";
        gdc = "git diff --cached";
        gfp = "git format-patch";
        glf = "git logfix";
        glfh = "git --no-pager logfix -n1";
        gloh = "git --no-pager log --oneline -n10";
        gpta = "git powertree-add";
        gptr = "git powertree-register";
      };

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      envExtra = ''
        HKML_DIR=/home/eberman/.cache/hkm
        ZSH_TMUX_AUTOREFRESH=true
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        {
          plugin = dotbar;
          extraConfig = ''
            set -g status-interval 1
            set -g @tmux-dotbar-right true

            # Theme-agnostic contrast: everything is fg=default (the terminal
            # foreground), and "dim" is the FAINT attribute (SGR 2), not a fixed
            # color. The terminal renders faint relative to the live background,
            # so dim text recedes in both light and dark mode — a fixed gray
            # can't (it sits near the dark bg but far from the light bg).
            #   bright: active window, session name, numbers = default
            #   dim:    inactive windows, hostname, glyphs   = default + faint
            # NB: faint (SGR 2) and bold (SGR 1) are mutually exclusive, so the
            # dim elements are no longer bold.
            # The bright styles need an explicit nodim: dim (SGR 2) set by an
            # inactive window persists until cleared, so without nodim it bleeds
            # into the active window and both look dim.
            set -g @tmux-dotbar-bg default
            set -g @tmux-dotbar-fg "default,dim"
            set -g @tmux-dotbar-fg-current "default,nodim"
            set -g @tmux-dotbar-fg-session "default,nodim"
            set -g @tmux-dotbar-fg-prefix brightgreen
            set -g @tmux-dotbar-bold-current-window false

            # Left: session name (bright) + hostname (dim/faint).
            # NB: no commas inside #[...] here — dotbar nests this in
            # #{?client_prefix,...,} and tmux splits the conditional on commas.
            set -g status-left-length 100
            set -g @tmux-dotbar-session-text " #[nodim]#S#[dim] on #([ -n \"$SSH_CONNECTION\" ] && echo -n \"#[nodim]󰌘#[dim] \")#H "

            # Right: live CPU / memory / network / disk metrics.
            set -g status-right-length 100
            # Single-quote the id: tmux expands #{session_id} to '$0', '$1', …
            # then runs the line via `sh -c`, which would otherwise expand those
            # as shell positional params (\$0 -> "sh", \$1 -> empty).
            set -g @tmux-dotbar-status-right "#(${lib.getExe pkgs.tmux-status} '#{session_id}')"
          '';
        }
        fingers
        sensible
        yank
      ];
      # screen (the module default) advertises only 8 colors, so tmux clamps
      # the 256-color status palette into a few near-identical shades. Use
      # tmux-256color so colourNNN renders correctly.
      terminal = "tmux-256color";
      mouse = true;
      keyMode = "vi";
      historyLimit = 100000;
      extraConfig = ''
        set -g set-titles on

        # Status bar at the top with a horizontal rule beneath it (like the
        # border between stacked panes). tmux orders status-format top-to-bottom
        # (index 0 = topmost), so the dotbar bar stays in the default
        # status-format[0] and we only add the rule as status-format[1]. The
        # rule is a long run of ─ that tmux clips to the client width (status
        # lines are single-line, never wrapped), so it adapts to any size.
        set -g status-position top
        set -g status 2
        set -g 'status-format[1]' "#[fg=default,dim]${lib.concatStrings (lib.replicate 400 "─")}"

        set -g allow-passthrough on
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'

        set -g update-environment "DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"
      '';
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
