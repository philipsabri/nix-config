{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options = {
    module.git.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Git.";
    };

  };

  config = mkIf config.module.git.enable {
    programs.git = {
      enable = true;

      userName = lib.mkDefault "Philipsabri";
      userEmail = lib.mkDefault "philipsabri@gmail.com";

      extraConfig = {
        push.autoSetupRemote = true;

        core = {
          editor = "code --wait";
        };

        ghq = {
          root = "~/git";
        };
      };

      signing = {
        key = lib.mkDefault "A387BEADA856647C";
        signByDefault = true;
      };
    };

    home.packages = [
      pkgs.ghq
    ];
  };
}
