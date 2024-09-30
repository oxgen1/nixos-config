{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
    ./git.nix
    ./starship.nix
    ./vscode/vscode.nix
  ];
}