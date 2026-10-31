{
  home-manager,
  nix4vscode,
  nix-remote-utils,
  self,
  ...
}@flakeInputs:
{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    home-manager.nixosModules.home-manager
    (import ./eberman.nix flakeInputs)
    (import ./desktop.nix flakeInputs)
  ];

  nixpkgs.overlays = [
    nix-remote-utils.overlays.default
    nix4vscode.overlays.default
    self.overlays.default
  ];

  users.mutableUsers = false;

  boot.tmp.cleanOnBoot = true;

  programs = {
    vim = {
      enable = true;
      defaultEditor = true;
    };
    zsh.enable = true;
    ssh.setXAuthLocation = true;
  };

  # Unlink stale ~/.opener.sock on bind so opener's SSH RemoteForward survives reconnects.
  services.openssh.settings.StreamLocalBindUnlink = "yes";

  services = {
    udev.extraRules = ''
      # For Jetson AGX Orin Dev Kit board automation
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7045", GROUP="dialout", TAG+="uaccess"
      # For Jetson Orin Nano Dev Kit board automation
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7020", GROUP="dialout", TAG+="uaccess"
      # For Qualcomm products
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="05c6", MODE="0664", GROUP="dialout"
      # For fastboot
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="d00d", MODE="0664", GROUP="dialout"
    '';
  };

  # geoclue2 overridden to 2.8.1 (nixpkgs PR#519210, unmerged) for [ip] method=,
  # since wifi geolocation isn't always reliable. See ../pkgs-overlays/geoclue2.nix.
  environment.etc = lib.mkIf config.services.geoclue2.enable {
    "geoclue/conf.d/90-ip.conf".text = ''
      [ip]
      enable=true
      method=reallyfreegeoip
    '';
  };

  environment.enableAllTerminfo = true;
  environment.systemPackages = with pkgs; [
    python3
    git
  ];

  time.timeZone = "America/Los_Angeles";

  networking.networkmanager.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = config.programs.virt-manager.enable;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  # Disable ModemManager because it interferes with Qualcomm EDL. It gets started
  # automatically by default, but I'm not likely to plug in a modem.
  systemd.services.ModemManager.enable = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  documentation.dev.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
