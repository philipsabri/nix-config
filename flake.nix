{
  description = "Philip's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      nix-vscode-extensions,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      flake = {
        homeModules = nixpkgs.lib.mkMerge [
          #./modules/default.nix
          #./home/default.nix
          {
            user-philip =
              { pkgs, ... }:
              {
                imports = [
                  ./modules/default.nix
                ];
              };
          }
        ];
        # Build darwin flake using:
        # $ darwin-rebuild switch --flake ~/nix/nix-config
        darwinConfigurations."philips-MacBook-Air" = nix-darwin.lib.darwinSystem {
          #system = "aarch64-darwin";
          modules = [
            ./system/mac.nix
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ({
              users.users.philip = {
                name = "philip";
                home = "/Users/philip";
              };
            })
          ];
          specialArgs = {
            inherit self;
            inherit nix-vscode-extensions;
            inherit homebrew-core;
            inherit homebrew-cask;
          };
        };
      };
    };
}
