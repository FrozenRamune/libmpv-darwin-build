{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "libmoltenvk";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };

  /*
  fetchDependency = { owner, repoName }: builtins.fetchGit {
    url = "https://github.com/${owner}/${repoName}.git";
    ref = "main";
    rev = builtins.readFile ${src}/ExternalRevisions/${repoName}_repo_revision;
  };

  cereal = fetchDependency {
    owner = "USCiLab";
    repoName = "cereal";
  };
  vulkanHeaders = fetchDependency {
    owner = "KhronosGroup";
    repoName = "Vulkan-Headers";
  };
  spirvCross = fetchDependency {
    owner = "KhronosGroup";
    repoName = "SPIRV-Cross";
  };
  spirvTools = fetchDependency {
    owner = "KhronosGroup";
    repoName = "SPIRV-Tools";
  };
  spirvHeaders = fetchDependency {
    owner = "KhronosGroup";
    repoName = "SPIRV-Headers";
  };
  vulkanTools = fetchDependency {
    owner = "KhronosGroup";
    repoName = "Vulkan-Tools";
  };
  volk = fetchDependency {
    owner = "KhronosGroup";
    repoName = "Volk";
  };
  */

  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}"
    {
      nativeBuildInputs = [
        pkgs.git
      ];
    }
    ''
      cp -r ${src} src
      export src=$PWD/src
      chmod -R 777 $src

      cd $src
      # ./fetchDependencies --$(echo ${os} | sed 's/simulator$/sim/')
      cd -

      cp -r $src $out
    '';
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      -DMVK_CONFIG_LOG_LEVEL=1
  '';
  buildPhase = ''
    meson compile -vC build $(basename $src)
  '';
  installPhase = ''
    # manual install to preserve symlinks (meson install -C build)
    cp -r build/dist$out $out
  '';
}
