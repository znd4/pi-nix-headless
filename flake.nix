{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      exampleIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            environment.systemPackages = [ pkgs.neovim ];
          })
        ];
      };
    };
  };
}
