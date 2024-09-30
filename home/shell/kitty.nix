{config, pkgs, ...}:

{
    programs.kitty = {
        enable = true;
        font = "ZedMono Nerd Fontkit";
        shellIntegration.enableFishIntegration = true;
    };
}