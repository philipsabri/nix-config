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
      default = true;
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
        programs = {
          carapace.enable = true; # completions
          #starship.enable = true; # prompt
          atuin.enable = true; # history

          nushell = {
            enable = true;
            settings.completions.algorithm = "fuzzy";
            shellAliases = {
              "ll" = "ls -la";
              "k" = "kubectl";
              "update-nix" = "sudo nixos-rebuild switch";
              "glogin" = "gcloud auth login --update-adc";
            };
            envFile.text = ''
              $env.GPG_TTY = (tty)
              $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
            '';
            environmentVariables = {
              KUBE_EDITOR = "code --wait";
              GOPATH = "${config.home.homeDirectory}/go";

              #CUDA_PATH = "${pkgs.cudatoolkit}";
              #LD_LIBRARY_PATH = "/usr/lib/wsl/lib:${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib";
              #EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
              #EXTRA_CCFLAGS = "-I/usr/include";
            };
            extraConfig = ''
              def __complete_kubectx [] { kubectx | lines }
              export extern kubectx [context?: string@__complete_kubectx]
              def __complete_kubens [] { kubens | lines }
              export extern kubens [namespace?: string@__complete_kubens]
            '';
          };
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
