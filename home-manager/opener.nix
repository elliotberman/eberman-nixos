# opener (github.com/superbrothers/opener): open URLs from an SSH-connected
# headless host in the local machine's browser. nixpkgs' `opener` package ships
# only the daemon binary, so the systemd user service and the fake `xdg-open`
# are defined here. Two independent roles:
#   - daemon.enable  → the machine WITH the browser (laptop): runs the opener
#     daemon listening on ~/.opener.sock; it invokes the real xdg-open.
#   - remote.enable  → the headless machine (devserver): installs a fake
#     `xdg-open` that pipes its URL argument to ~/.opener.sock (remote-forwarded
#     over SSH) via `nc -U`, so it reaches the laptop daemon. Also sets
#     BROWSER=xdg-open so tools using Python's stdlib `webbrowser` (e.g.
#     `aws sso login`) find it — webbrowser only auto-registers xdg-open when
#     DISPLAY/WAYLAND_DISPLAY is set (never true over plain SSH), but always
#     honours BROWSER regardless of DISPLAY.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.eberman.opener;

  # Upstream's fake xdg-open (bin/xdg-open), verbatim behaviour: send the URL to
  # the forwarded socket. netcat-openbsd is wrapped in via runtimeInputs so the
  # correct `nc` (with unix-socket -U support) is always used.
  fake-xdg-open = pkgs.writeShellApplication {
    name = "xdg-open";
    runtimeInputs = [ pkgs.netcat-openbsd ];
    text = ''
      if (( $# == 0 )) ; then
        buf=$(cat)
      else
        buf=$*
      fi
      echo "$buf" | nc -U "$HOME/.opener.sock"
    '';
  };
in
{
  options.eberman.opener = {
    daemon.enable = lib.mkEnableOption "opener daemon (runs on the machine with the browser)";
    remote.enable = lib.mkEnableOption "opener fake xdg-open (runs on the headless SSH host)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.daemon.enable {
      # User service so the daemon inherits the graphical session env
      # (DISPLAY/DBUS) it needs to hand the URL to the real xdg-open/browser.
      # After= enforces start ordering so DISPLAY/DBUS are available at launch.
      # No Environment PATH override: the inherited graphical-session PATH
      # already provides xdg-open, gio, and all desktop helpers it delegates to.
      systemd.user.services.opener = {
        Unit = {
          Description = "opener daemon — open forwarded URLs in the local browser";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe pkgs.opener;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })

    (lib.mkIf cfg.remote.enable {
      # Shadows the system xdg-open on PATH for this user.
      home.packages = [ fake-xdg-open ];
      # Force Python's `webbrowser` (used by `aws sso login`, many CLIs) to use
      # the fake xdg-open. Without DISPLAY set — as over plain SSH — webbrowser
      # never registers xdg-open on its own, so it would otherwise fail to open
      # anything despite xdg-open being on PATH.
      home.sessionVariables.BROWSER = "xdg-open";
    })
  ];
}
