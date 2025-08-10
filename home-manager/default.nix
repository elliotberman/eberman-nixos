{nix-index, ...}@flakeInputs:
{ pkgs, ... }:
{
    imports = [ nix-index.homeModules.nix-index ./shell.nix  ];
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
        ];
    };

    programs = {
        home-manager.enable = true;

        git = {
            enable = true;
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
