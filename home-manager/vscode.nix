{ pkgs, config, ... }:
let
  vscode = config.programs.vscode.package;
  nix-vscode-extensions' = pkgs.nix-vscode-extensions;
  extensions-latest = nix-vscode-extensions'.vscode-marketplace;
  extensions-compat =
    (nix-vscode-extensions'.forVSCodeVersion vscode.version).vscode-marketplace-release;
  extensions = extensions-latest // extensions-compat;
in
{
  programs.vscode = {
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with extensions; [
        arrterian.nix-env-selector
        catppuccin.catppuccin-vsc
        christian-kohler.path-intellisense
        eamodio.gitlens
        editorconfig.editorconfig
        github.vscode-pull-request-github
        jaycetyle.vscode-gnu-global
        jlevere.elfpreview
        jnoortheen.nix-ide
        johnpapa.vscode-peacock
        legale.dts-formatter
        luveti.kconfig
        mkhl.direnv
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-explorer
        plorefice.devicetree
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        timonwong.shellcheck
        wayou.vscode-todo-highlight
      ];

      enableUpdateCheck = false;

      enableExtensionUpdateCheck = false;
      userSettings = {
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = [
                "nix"
                "fmt"
                "--"
                "--no-cache"
              ];
            };
          };
        };
        "nix.enableLanguageServer" = true;
        "nix.hiddenLanguageServerErrors" = [
          "textDocument/formatting"
          "textDocument/documentSymbol"
          "textDocument/definition"
        ];
        "path-intellisense.extensionOnImport" = true;
        "window.restoreWindows" = "none";
        "editor.renderWhitespace" = "boundary";
        "terminal.integrated.allowChords" = false;
        "files.simpleDialog.enable" = true;
        "editor.rulers" = [
          80
          100
          120
        ];
        "editor.fontFamily" = "monospace";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 8;
        "update.mode" = "none";
        "nixEnvSelector.useFlakes" = true;
        "[rust]" = {
          "editor.tabSize" = 4;
          "editor.formatOnSave" = true;
        };
        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;

        "window.autoDetectColorScheme" = true;
        "workbench.preferredLightColorTheme" = "Quiet Light";
        "workbench.preferredDarkColorTheme" = "Catppuccin Frappé";

        "remote.SSH" = {
          "externalSSH_ASKPASS" = true;
          "lockfilesInTmp" = true;
          "configFile" = "/home/eberman/.vscode/ssh_config";
        };
      };
    };
  };
}
