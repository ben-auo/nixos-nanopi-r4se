{
  description = "NanoPi R4Se example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };
  outputs = { self, nixpkgs }:
  let
    pkgs = import "${nixpkgs}" {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    exampleBase = {
      system = "aarch64-linux";
      modules = [
        # Common system modules...
        ./baseline.nix
      ];
    };
  in {
      nixosConfiguration = nixpkgs.lib.nixosSystem {
        inherit (exampleBase) system;
        modules = exampleBase.modules ++ [
          # Modules for installed systems only.
        ];
      };

      sd = nixpkgs.lib.nixosSystem {
        inherit (exampleBase) system;
        modules = exampleBase.modules ++ [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
          ./sd-image.nix
        ];
      };

      uboot = (pkgs.buildUBoot {
        defconfig = "nanopi-r4se-rk3399_defconfig";
        extraPatches = [ ./patches/arm64-rk3399-Add-support-NanoPi-R4s.patch ];
        extraMeta = {
          platforms = [ "aarch64-linux" ];
        };
        BL31 = "${pkgs.armTrustedFirmwareRK3399}/bl31.elf";
        filesToInstall = [ "spl/u-boot-spl.bin" "u-boot.itb" "idbloader.img"];
      });
    };
}
