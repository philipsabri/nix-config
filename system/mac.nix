{
  self,
  pkgs,
  config,
  nix-vscode-extensions,
  home-manager,
  homebrew-core,
  homebrew-cask,
  nix-homebrew,
  home,
  ...
}:
{
  environment.systemPackages = [
    pkgs.mkalias
    pkgs.home-manager
  ];

  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "docker"
      "yubico-authenticator"
    ];
    masApps = {
      Bitwarden = 1352778147;
    };
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    enable = true;
    user = "philip";
    enableRosetta = true;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };

  # yubikey
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.philip = {
      imports = [ ./../home/default.nix ];
      home.packages = [
        pkgs.discord
        pkgs.spotify
        pkgs.qbittorrent
        pkgs.kind
      ];
    };
  };

  system.primaryUser = "philip";

  # pkgs apps will be visible in Spotlight
  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
    in
    pkgs.lib.mkForce ''
      # Set up system applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
      # Set up home-manager applications.
      cd "${config.users.users.philip.home}/Applications/Home Manager Apps/"
      find . -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  system.defaults = {
    dock.autohide = true;
    dock.persistent-apps = [
      "${pkgs.vscode}/Applications/Visual Studio Code.app"
      "/Applications/Google Chrome.app"
      "/System/Applications/Utilities/Terminal.app"
    ];
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # Sudo with fingerprint
  security.pam.services.sudo_local.touchIdAuth = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [
      nix-vscode-extensions.overlays.default
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
