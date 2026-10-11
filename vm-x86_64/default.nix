{ ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  services.xserver.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "eberman";
  };

  # Test-only; users.mutableUsers = false means there is otherwise no login.
  users.users.eberman.password = "test";

  # The qemu resolution below only sizes the window; the guest mode needs a kernel arg.
  virtualisation.vmVariant.boot.kernelParams = [ "video=Virtual-1:1920x1080" ];

  services.openssh.enable = true;

  virtualisation.vmVariant.virtualisation = {
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
    memorySize = 8192;
    cores = 4;
    diskSize = 20480;
    resolution = {
      x = 1920;
      y = 1080;
    };
    qemu.options = [
      "-device virtio-vga"
      "-display gtk"
    ];
  };
}
