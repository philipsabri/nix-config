{ config, pkgs, ... }:

{
  imports = [
    ./vscode.nix
    ./nushell.nix
    ./git.nix
    ./tools.nix
  ];
}
