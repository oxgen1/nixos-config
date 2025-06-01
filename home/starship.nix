{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };
}
