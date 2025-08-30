{ nix-index, vscode-server, ... }:
{ pkgs, ... }:
{
  imports = [
    nix-index.homeModules.nix-index
    ./desktop.nix
    ./mail.nix
    ./shell.nix

    vscode-server.homeModules.default
    ./vscode.nix
  ];
  home = {
    username = "eberman";
    homeDirectory = "/home/eberman";

    packages = with pkgs; [
      bitwise
      binutils
      cloc
      dtc
      file
      fzf
      gawk
      git-absorb
      git-credential-manager
      global
      gnupg
      htop
      jq
      lshw
      ltrace
      moreutils
      ncdu
      neofetch
      nix-fast-build
      nix-output-monitor
      nixd
      nixfmt-rfc-style
      nnn
      oh-my-zsh
      parted
      qdirstat
      ripgrep
      sshpass
      strace
      tio
      tree
      unzip
      usbutils
      vim
      wget
      which
      xz
      yq-go
      zip
      zsh
      zstd

      (writeShellApplication {
        name = "hkml";
        runtimeInputs = [
          git
          python3
        ];
        text =
          let
            src = fetchFromGitHub {
              owner = "sjp38";
              repo = "hackermail";
              tag = "v1.4.3";
              hash = "sha256-1r7sDugXODvvSZchVRTrxAzUM0126p8lzbGqKLurKIA=";
            };
          in
          ''
            python "${src}/src/hkml.py" "$@"
          '';
      })
    ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "Elliot Berman";
      userEmail = "elliotjb@elliotjb.com";

      extraConfig = {
        core.editor = "vim";
        init.defaultBranch = "main";
        color.ui = "auto";

        rebase = {
          autoStash = true;
          autoSquash = true;
          abbreviateCommands = true;
          rebaseMerges = true;
          missingCommitsCheck = "warn";
          updateRefs = "true";
        };

        advice.mergeConflict = false;
        merge.autoStash = true;

        alias = {
          logfix = ''log --format="Fixes %h (\"%s\")" --abbrev=12'';
          logad = "log --pretty='format:%C(auto)%h <%C(auto,blue)%aE%C(auto,reset) %C(auto,green)%ah%C(auto,reset) %s'";
        };

        sendemail = {
          smtpServer = "mail.privateemail.com";
          smtpServerPort = "465";
          smtpEncryption = "ssl";
          smtpUser = "elliotjb@elliotjb.com";
        };
      };
    };

    ssh.enable = true;
  };

  services = {
    podman.enable = true;
    mpris-proxy.enable = true;
  };

  home.stateVersion = "25.05";
}
