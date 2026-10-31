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