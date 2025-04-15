{ config, pkgs, ... }:

{
  imports = [
    ./vscode.nix
    ./nushell.nix
  ];
}
