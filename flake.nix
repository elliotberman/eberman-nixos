{
  description = "Elliot's nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
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

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-remote-utils = {
      url = "github:elliotberman/nix-remote-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";
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

      generatePkgs =
        pkgs:
        nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./pkgs;
        };
    in
    {
      nixosModules = {
        default = import ./nixos-modules flakeInputs;
      };

      homeConfigurations = {
        eberman = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [
              flakeInputs.nix-remote-utils.overlays.default
              flakeInputs.nix4vscode.overlays.default
            ];
          };
          modules = [ (import ./home-manager flakeInputs) ];
        };
      };

      nixosConfigurations = {
        wslx86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
            nixos-wsl.nixosModules.default
            ./wsl-x86_64
          ];
        };
      };

      overlays.default = pkgs: _: generatePkgs pkgs;

      legacyPackages = forEachSystem generatePkgs;

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
