{ pkgs, ... }:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
        package.disabled = true;
        rust.disabled = true;
        shell.disabled = false;
        shell.zsh_indicator = "";

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

        kerntags = "rm *TAGS; make ARCH=arm64 gtags";
      };

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      envExtra = ''
        HKML_DIR=/home/eberman/.cache/hkm
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
        yank
        sensible
        fingers
        tmux-fzf
      ];
      mouse = true;
      keyMode = "vi";
      historyLimit = 50000;
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
