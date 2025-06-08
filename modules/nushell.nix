{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options = {
    module.nushell.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nushell.";
    };
    module.nushell.mac = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nushell on macOS.";
    };
  };

  config = mkIf config.module.nushell.enable (
    lib.mkMerge [
      {
        programs.nushell = {
          enable = true;
          shellAliases = {
            "ll" = "ls -la";
            "k" = "kubectl";
          };
          envFile.text = ''
            $env.GPG_TTY = (tty)
            $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
          '';
        };
      }
      (mkIf config.module.nushell.mac {
        home.packages = [
          pkgs.nushell
        ];
        programs.zsh = {
          enable = true;
          loginExtra = ''
            nu
          '';
        };
      })
    ]
  );
}
