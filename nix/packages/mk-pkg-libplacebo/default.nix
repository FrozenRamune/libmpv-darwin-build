{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "libplacebo";
  packageLock = (import ../../../packages_git.lock.nix).${name};

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  inherit (packageLock) rev;

  pname = import ../../utils/name/package.nix name;
  src = callPackage builtins.fetchGit {
    inherit (packageLock) url ref;
    inherit rev;
    submodules = true;
  };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${rev}";
  pname = pname;
  version = rev;
  inherit src;
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
      --wipe \
      -Dbuildtype=release \
      -Db_lto=true \
      -Db_lto_mode=thin \
      -Dvulkan=disabled \
      -Dshaderc=disabled \
      -Dxxhash=disabled \
      -Dopengl=enabled \
      -Dd3d11=disabled \
      -Dglslang=disabled \
      -Ddemos=false \
      --default-library=static
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build
  '';
}
