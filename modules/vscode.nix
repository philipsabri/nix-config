{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.module.vscode;

  defaultUserSettings = {
    "files.autoSave" = "afterDelay";
    "files.autoSaveDelay" = 1000;
    "update.mode" = "none";
    "editor.formatOnSave" = true;
    "editor.tabSize" = 2;
    "files.trimTrailingWhitespace" = true;
    "files.trimFinalNewlines" = true;
    "files.insertFinalNewline" = true;
    "chat.agentSkillsLocations" = {
      "~/git/github.com/philipsabri/skills/skills" = true;
    };
  };

  keybindings = [
    {
      key = "cmd+k";
      command = "terminal.focus";
    }
  ];

  extensionNames = [
    "eamodio.gitlens"
    "golang.go"
    "hashicorp.terraform"
    "esbenp.prettier-vscode"
    "redhat.vscode-yaml"
    "jnoortheen.nix-ide"
    "github.copilot"
    "github.copilot-chat"
  ];

  # Look up extension packages dynamically from attribute path strings
  sharedExtensionPackages = map (
    name: lib.getAttrFromPath (lib.splitString "." name) pkgs.vscode-extensions
  ) extensionNames;

  mergedUserSettings = lib.recursiveUpdate defaultUserSettings cfg.additionalSettings;
  settingsFile = pkgs.writeText "vscode-settings.json" (builtins.toJSON mergedUserSettings);
  keybindingsFile = pkgs.writeText "vscode-keybindings.json" (builtins.toJSON keybindings);
in
{
  options.module.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";

    wsl = {
      enable = lib.mkEnableOption "Visual Studio Code configuration for WSL";
    };

    additionalSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional VS Code settings to merge with default settings.";
    };
  };

  config = lib.mkMerge [
    # Auto-enable parent option if WSL submodule is enabled
    (lib.mkIf cfg.wsl.enable {
      module.vscode.enable = lib.mkDefault true;
    })

    # 1. Non-WSL Setup (macOS / Native Linux)
    (lib.mkIf (cfg.enable && !cfg.wsl.enable) {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;
        profiles.default = {
          extensions = sharedExtensionPackages;
          userSettings = mergedUserSettings;
          inherit keybindings;
        };
      };
    })

    # 2. WSL Setup: Copy combined settings directly into Windows AppData
    (lib.mkIf (cfg.enable && cfg.wsl.enable) {
      home.activation.syncVscodeWslSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CMD_EXE="/mnt/c/Windows/System32/cmd.exe"

        if [ -f "$CMD_EXE" ]; then
          WIN_USER=$("$CMD_EXE" /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
        else
          WIN_USER=""
        fi

        if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/$WIN_USER" ]; then
          WIN_CONFIG_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User"
          mkdir -p "$WIN_CONFIG_DIR"

          echo "Syncing VS Code settings for Windows user '$WIN_USER' to: $WIN_CONFIG_DIR"
          cp -f "${settingsFile}" "$WIN_CONFIG_DIR/settings.json"
          cp -f "${keybindingsFile}" "$WIN_CONFIG_DIR/keybindings.json"
          chmod 644 "$WIN_CONFIG_DIR/settings.json" "$WIN_CONFIG_DIR/keybindings.json"

          # Locate Windows VS Code CLI binary directly across standard install paths
          VSCODE_CLI=""
          if [ -f "/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin/code" ]; then
            VSCODE_CLI="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin/code"
          elif [ -f "/mnt/c/Program Files/Microsoft VS Code/bin/code" ]; then
            VSCODE_CLI="/mnt/c/Program Files/Microsoft VS Code/bin/code"
          fi

          if [ -n "$VSCODE_CLI" ]; then
            echo "Syncing VS Code extensions via Windows interop CLI ($VSCODE_CLI)..."
            ${lib.concatMapStrings (ext: ''
              "$VSCODE_CLI" --install-extension "${ext}" --force >/dev/null 2>&1 || true
            '') extensionNames}
          else
            echo "Warning: Windows VS Code CLI binary not found. Skipping extension sync."
          fi
        else
          echo "Error: Could not determine Windows username via cmd.exe or directory under /mnt/c/Users/"
        fi
      '';
    })
  ];
}