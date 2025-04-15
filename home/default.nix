{ config, pkgs, ... }:

{
  imports = [
    ../modules/default.nix
  ];
  module.vscode.enable = true;

  home = {
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
  };
}
