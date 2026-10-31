{ pkgs, ... }:
{
  home-manager.users.eberman = {
    home.packages = with pkgs; [
      bitwarden-cli
      bitwarden-desktop
    ];

    home.sessionVariables = {
      SSH_AUTH_SOCK = "/home/eberman/.bitwarden-ssh-agent.sock";
    };

    programs.git.settings = {
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsrN0GPOLPT9aaSO5R+VhJcGKDf7w3R8ng+omJrdu3";
      gpg.format = "ssh";
      commit.gpgsign = true;
    };

    programs.ssh = {
      enable = true;
      settings = {
        "default" = {
          header = "Host *";
          IdentityAgent = "/home/eberman/.bitwarden-ssh-agent.sock";
        };
      };
    };
  };
}