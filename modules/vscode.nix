{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options = {
    module.vscode.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Visual Studio Code.";
    };

  };

  config = mkIf config.module.vscode.enable {
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          eamodio.gitlens
          golang.go
          hashicorp.terraform
          esbenp.prettier-vscode
          redhat.vscode-yaml
          jnoortheen.nix-ide
          github.copilot
          github.copilot-chat
        ];
        userSettings = {
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "update.mode" = "none";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
          "files.trimTrailingWhitespace" = true;
          "files.trimFinalNewlines" = true;
          "files.insertFinalNewline" = true;
        };
        keybindings = [
          {
            key = "cmd+k";
            command = "terminal.focus";
          }
        ];
      };
    };
  };
}
