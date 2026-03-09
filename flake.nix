{
  description = "Eiri's Pure Flake Config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # home-manager.url = "github:nix-community/home-manager/master";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, home-manager, vscode-server, ... }: {
    nixosConfigurations.eiri-coffee = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.eiri = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }
        vscode-server.nixosModules.default (
          { config, pkgs, ... }: {
            services.vscode-server.enable = true;
          }
        )
      ];
    };
  };
}
