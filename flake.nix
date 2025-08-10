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
      ...
    }:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {

      nixosConfigurations = {
        wslx86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            nixos-wsl.nixosModules.default
            {
              nixpkgs.hostPlatform = "x86_64-linux";
              system.stateVersion = "25.05";
              wsl.enable = true;
            }
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
