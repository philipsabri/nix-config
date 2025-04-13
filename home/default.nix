{ config, pkgs, ... }:

{
  home = {
    username = "philip";
    homeDirectory = "/Users/philip";

    sessionVariables = {
      EDITOR = "code";
      SHELL = "nu";
      FOO = "Hello2";
    };

    packages = [
      pkgs.wget
      pkgs.gnupg
      pkgs.nixfmt-rfc-style

      pkgs.kubectl
      pkgs.kubernetes-helm
    ];

    stateVersion = "24.11";
  };

  programs = {
    home-manager.enable = true;

    nushell = {
      enable = true;
      shellAliases = {
        "ll" = "ls -la";
      };
      envFile.text = ''
        $env.GPG_TTY = (tty)
        $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
      '';
    };

    git = {
      enable = true;

      userName = "Philipsabri";
      userEmail = "philipsabri@gmail.com";

      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };

      signing = {
        key = "A387BEADA856647C";
        signByDefault = true;
      };

    };

    vscode = {
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
