{
  description = "Elliot's nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      systems,
      treefmt-nix,
      home-manager,
      ...
    }@flakeInputs:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      nixosModules = {
        default = import ./nixos-modules flakeInputs;
      };

      nixosConfigurations = {
        wslx86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
            nixos-wsl.nixosModules.default
            (
              { pkgs, lib, ... }:
              {
                nixpkgs.hostPlatform = "x86_64-linux";
                system.stateVersion = "25.05";
                wsl.enable = true;
                wsl.defaultUser = "eberman";

                networking.networkmanager.enable = lib.mkForce false;

                home-manager.users.eberman.programs = {
                  zsh.profileExtra = ''
                    export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
                    ${lib.getExe' pkgs.iproute2 "ss"} -a | grep -q $SSH_AUTH_SOCK
                    if [ $? -ne 0   ]; then
                        rm -f $SSH_AUTH_SOCK
                        ( setsid ${lib.getExe pkgs.socat} UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"/mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
                    fi
                  '';

                  git.extraConfig = {
                    gpg.format = "ssh";
                    user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsrN0GPOLPT9aaSO5R+VhJcGKDf7w3R8ng+omJrdu3 elliot";
                    commit.gpgsign = true;

                    credential.helper = "manager";
                    credential.credentialStore = "none";
                  };
                };
              }
            )
          ];
        };
      };

      formatter = forEachSystem (
        pkgs:
        (treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          }
        )).config.build.wrapper
      );

    };
}
