{
	description = "Spoons Flake";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
        blender-bin.url = "https://flakehub.com/f/edolstra/blender-bin/*";
	};

	outputs = { self, nixpkgs, home-manager, blender-bin, ... }: {
		nixosConfigurations.spoon = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
            specialArgs = {
                inherit blender-bin;
            };
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.spoon = import ./home.nix;
						backupFileExtension = "backup";
					};
				}
			];
		};
	};
}
