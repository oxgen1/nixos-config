{
  description = "NixOS Config";

  inputs = {
    
     # Official NixOS package source, using nixos's unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    nixosConfigurations.jacks-pc = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # this is the important part
      system = "x86_64-linux";
      modules = [
        ./desktop/configuration.nix
        
         home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jack = import ./home;
          }
      ];
    };

    nixosConfigurations.jacks-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # this is the important part
      system = "x86_64-linux";
      modules = [
        ./laptop/configuration.nix
        
         home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jack = import ./home;
          }
      ];
    };
  };
}