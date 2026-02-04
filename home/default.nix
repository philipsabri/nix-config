{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/default.nix
  ];
  module.vscode.enable = true;
  module.git.enable = true;
  module.nushell = {
    enable = true;
    mac = true;
  };

  home = {
    sessionVariables = {
      EDITOR = "code";
      SHELL = "nu";
      FOO = "Hello2";
    };

    packages = [
      pkgs.wget
      pkgs.gnupg
      pkgs.pkgs.nixfmt

      pkgs.kubectl
      pkgs.kubernetes-helm
    ];

    stateVersion = "24.11";
  };

  programs = {
    home-manager.enable = true;
    go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
    };
  };
}
