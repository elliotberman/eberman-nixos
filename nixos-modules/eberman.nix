flakeInputs:
{ pkgs, ... }:
{
    users.users.eberman = {
        description = "Elliot Berman";
        isNormalUser = true;
        extraGroups = [
            "adbusers"
            "dialout"
            "disk"
            "docker"
            "networkmanager"
            "wheel"
        ];

        shell = pkgs.zsh;

        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsrN0GPOLPT9aaSO5R+VhJcGKDf7w3R8ng+omJrdu3"
        ];
    };

    home-manager.users.eberman = (import ../home-manager flakeInputs);

    nix.settings.trusted-users = [ "eberman" ];
}
