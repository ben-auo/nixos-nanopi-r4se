{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  #nixpkgs.crossSystem.system = "aarch64-linux";
  #nixpkgs.config.allowBroken = true;

  # building with emulation
  #nixpkgs.system = "aarch64-linux";

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel.nix
      {
        kernelPatches = [
  {
    name = "NanoPi-R4S-dts";
    patch = ./patches/rockchip-rk3399-add-support-for-FriendlyARM-NanoPi-R4S.patch;
  }
  #r4s-doc = {
    #name = "NanoPi-R4S-doc";
    #patch = ./patches/dt-bindings-Add-doc-for-FriendlyARM-NanoPi-R4S.patch;
  #};
        ];
        #kernelPatches = [ r4s-dts r4s-doc ];
      });
    #pkgs.linuxPackagesNanopiR4S;
    kernelParams = ["cma=32M" "console=ttyS2,115200n8" "console=tty0"];
  };
  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it.
    compressImage = false;
    populateFirmwareCommands = '''';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  # Enable OpenSSH
  services.sshd.enable = true;

  # root autologin etc
  users.users.root.password = "root";
  services.openssh.permitRootLogin = lib.mkDefault "yes";
  services.getty.autologinUser = lib.mkDefault "root";

  #users.extraUsers.root.openssh.authorizedKeys.keys = [
  #   ""
  #];

  networking.firewall.enable = false;
}
