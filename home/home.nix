{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jack";
  home.homeDirectory = "/home/jack";

  home.packages = with pkgs; [
    dig
    mtr
    conntrack-tools
    hping
    tcpdump
    # exodus
    cura-appimage
  ];

  programs.direnv = {
      enable = true;
      enableFishIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}