{home-manager, ... }@flakeInputs:
{ pkgs, config, ... }:
{
    imports = [
        home-manager.nixosModules.home-manager
        (import ./eberman.nix flakeInputs)
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
