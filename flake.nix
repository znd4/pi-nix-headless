{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixos-generators = {
    url = "github:nix-community/nixos-generators";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
      ...
    }:
    {
      nixosModules = {
        system = (
          { pkgs, modulesPath, ... }:
          {
            imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];
            systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
            services.openssh = {
              enable = true;
              # require public key authentication for better security
              settings.PasswordAuthentication = false;
              settings.KbdInteractiveAuthentication = false;
              # settings.PermitRootLogin = "yes";
            };
            users.mutableUsers = false;
            system.stateVersion = "24.05";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            users.users =
              let
                user = "znd4";
              in
              {
                "${user}" = {
                  isNormalUser = true;
                  openssh.authorizedKeys.keys = [
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCl0b5lRgbKt6zTP1IUaAV+qsPtAPEXVDAnTbYUgtlGO6NqOtKkQbrsB6joODTWtNswsOWfGGE8BjyGzXeSVUsnaR9RmxpBvN0xJvBqtmDayLOrkTj8dxJzt4lvvGUjy+nt7h2t2aGYVBhqhsmdTM/8cKPeEb1/fCZRDAEAgt4SVhEk/Bh+UrHVk6ZOtJzlmw671+HCj84f3fJIls+DBIPGHWG8kYHRQcr4b9bvibxi9d+EMr6MZY16Hd78pJKSnXGUPbmN10jsUJGfTv/c2ZUTuhJxeRqP4ZGK3IKG8I3lGbxG11QAG83CtjJzbYaWODcZZ5jlJ656vEc1B1tQNTKGMBi9xPWGZZerkkw8bwwlod0ipYReOMe/VGtwU0be3MbUFLghClh8zlZzJa33t5QK20tZdOjqKG6ycqEPhDt83QjHIV4plgUtIJDC9tooZgVTc7A8n0kuLtm/Fk7PoHaGF9j3QcwWABlpZgZJbLISW3tqHVF6blI2/u9wXmK+U0NIsz7C5RjhLhM4Lays9K+wcSGM5BGdXvsw8TbCy8CVqqDelhSkuoybMcQI6UPVk4K99jbIzjSMx2XFitFri37IvF8pSn0Var9rrN5ihYE5eOTm1R+HE4JpPJZ8JhIrs6feYfKQ0WXQrONTFv+rzEkK9V0bLcttZrKOiNnCZHTvdQ== ${user}"
                  ];
                  extraGroups = [ "wheel" ];
                };
              };
          }
        );
      };
      packages.aarch64-linux = {
        sdcard = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [ self.nixosModules.system ];
        };
        default = self.packages.aarch64-linux.sdcard;
      };
    };
}
