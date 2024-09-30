{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "j@jack.farm";
    userName = "Jack";
  };
}