{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.eberman.enableDesktop {
  xdg.desktopEntries.xdg-browser-dispatch = {
    name = "Browser Dispatch";
    exec = "${lib.getExe pkgs.xdg-browser-dispatch} %U";
    noDisplay = true;
    mimeType = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: "xdg-browser-dispatch.desktop");
  };
}
