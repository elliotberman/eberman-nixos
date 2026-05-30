{
  symlinkJoin,
  writeShellApplication,
  git,
}:
symlinkJoin {
  name = "git-powertree";
  paths = [
    (writeShellApplication {
      name = "git-powertree-add";
      runtimeInputs = [ git ];
      text = builtins.readFile ./add.sh;
    })
    (writeShellApplication {
      name = "git-powertree-register";
      runtimeInputs = [ git ];
      text = builtins.readFile ./register.sh;
    })
  ];
}
