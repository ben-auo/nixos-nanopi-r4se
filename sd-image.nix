{ config, pkgs, lib, modulesPath, ... }: {

  system.stateVersion = "22.11";

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];

  # minimal image
  boot.initrd.checkJournalingFS = false;
  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = [ "squashfs" "ext4" "overlay" ];
  boot.initrd.kernelModules = [ "squashfs" "ext4" "overlay" ];
  disabledModules =
    [ 
      (modulesPath + "/profiles/all-hardware.nix")
      (modulesPath + "/profiles/base.nix")
    ];
  environment.defaultPackages = [];
  xdg.icons.enable  = false;
  xdg.mime.enable   = false;
  xdg.sounds.enable = false;
  fonts.fontconfig.enable = lib.mkForce false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  documentation.dev.enable = false;

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
