{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options = {
    module.tools.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tools";
    };
  };

  config = mkIf config.module.tools.enable {
    home.packages = [
      pkgs.wget
      pkgs.gnupg
      pkgs.pkgs.nixfmt

      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.kind
      pkgs.ko

      pkgs.postgresql

      pkgs.terraform
      pkgs.opentofu

      (pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
          nomos
        ]
      ))
    ];
    programs = {
      go = {
        enable = true;
      };
    };
  };
}
