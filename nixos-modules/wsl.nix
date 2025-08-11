{ pkgs, lib, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "eberman";

  networking.networkmanager.enable = lib.mkForce false;

  home-manager.users.eberman = {
    services.vscode-server.enable = true;
    programs = {
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
  };
}
