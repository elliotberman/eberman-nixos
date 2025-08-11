{ pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
  imports = [
    ../nixos-modules/wsl.nix
  ];
}
