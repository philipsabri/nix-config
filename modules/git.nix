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
      default = false;
      description = "Enable Git.";
    };

  };

  config = mkIf config.module.git.enable {
    programs.git = {
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
