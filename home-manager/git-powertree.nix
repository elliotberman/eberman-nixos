{ pkgs, ... }:
{
  programs.zsh.shellAliases = {
    gptr = "git powertree-register";
    gpta = "git powertree-add";
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "git-powertree-register";
      runtimeInputs = [ pkgs.git ];
      text = ''exec ${./scripts/git-powertree/register.sh} "$@"'';
    })

    (pkgs.writeShellApplication {
      name = "git-powertree-add";
      runtimeInputs = [ pkgs.git ];
      text = ''exec ${./scripts/git-powertree/add.sh} "$@"'';
    })
  ];
}
