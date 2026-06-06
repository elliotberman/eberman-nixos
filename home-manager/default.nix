{ nix-index, vscode-server, ... }:
{
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}:
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
      binutils
      bitwise
      cloc
      dtc
      file
      fzf
      gawk
      git-absorb
      git-credential-manager
      git-powertree
      global
      gnupg
      hkml
      htop
      jq
      llvmPackages.libllvm
      lshw
      ltrace
      moreutils
      nbr
      ncdu
      nethogs
      nix-copy-as
      nix-fast-build
      nix-inspect
      nix-output-monitor
      nixd
      nnn
      nor
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
        name = "kerntags";
        runtimeInputs = [
          pkgsCross.aarch64-multiplatform.buildPackages.stdenv
        ];
        text = ''
          rm -- *TAGS || true
          make ARCH=arm64 gtags
        '';
      })

      (pkgs.linkFarm "code-connect" {
        "bin/code-connect" = lib.getExe pkgs.code-connect;
      })
    ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      package = pkgs.gitFull;

      settings = {
        user.name = "Elliot Berman";
        user.email = "elliotjb@elliotjb.com";
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

        "gpg \"ssh\"" = {
          allowedSignersFile = "~/.config/git/allowed-signers";
        };
      };
    };

    ssh = {
      enable = true;

      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        ServerAliveInterval = 20;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;

        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "5s";

        WarnWeakCrypto = "no";
      };
    };
  };

  services = {
    podman.enable = true;
    mpris-proxy.enable = true;
  };

  home.file."${config.home.homeDirectory}/.config/git/allowed-signers" = {
    text = ''
      eberman@anduril.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1y0we2CHRY4ETSrjucwle0oimNBFdhrDb4q3LZu1Sl
      elliot@elliotjb.com,elliotjb@elliotjb.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsrN0GPOLPT9aaSO5R+VhJcGKDf7w3R8ng+omJrdu3
    '';
    force = true;
  };

  home.stateVersion = "25.05";
}
