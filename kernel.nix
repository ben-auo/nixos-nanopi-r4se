{ stdenv, fetchFromGitHub, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

#with stdenv.lib;

buildLinux (args // rec {
  version = "6.1-rc8";
  #extraMeta.branch = "5.10";

  # modDirVersion needs to be x.y.z, will always add .0
  modDirVersion = if (modDirVersionArg == null) then builtins.replaceStrings ["-"] [".0-"] version else modDirVersionArg;

  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    rev = "v6.1-rc8";
    sha256 = "sha256-KSAotMNO3u+Y02txyCG7ax4YLt87Wwon6o2G8pMVZZY=";
  };

  #src = fetchurl {
    ##url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
    #url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    ##sha256 = "0p174gdlf0fj5xc7d56iddp2y09c4h94gk16x3psf30bpqg7v3b5";
    #sha256 = "0v3x1q1r0r8lyjg5hsj7yayfxqcgfj01p86ya4s0i9jaclpwv4ki";
  #};

  # Should the testing kernels ever be built on Hydra?
  extraMeta.hydraPlatforms = [];

} // (args.argsOverride or {}))
