{ home-manager, ... }@flakeInputs:
{ pkgs, config, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    (import ./eberman.nix flakeInputs)
    ./desktop.nix
  ];

  users.mutableUsers = false;

  boot.tmp.cleanOnBoot = true;

  programs = {
    vim = {
      enable = true;
      defaultEditor = true;
    };
    zsh.enable = true;
    adb.enable = true;
  };

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
    useUserPackages = false;
    backupFileExtension = "backup";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
