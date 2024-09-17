{pkgs, ...}:
rec {
  # Make a specific Haskell derivation build statically.
  # drv: Typically 'prev.callCabal2nix "${pname}" ./. {}', but can also be
  #      'prev.PACKAGE_NAME'
  # extraLibs: attrSet of (lname, drv) as required by mkCabalConfFlags.
  # Typical usage goes something like:
  # mkStatic pkgs.haskellPackages.microlens {};
  # mkStatic (prev.callCabal2nix "${pname}" ./. {}) {}
  mkStatic = drv: { extraLibs ? {}, doCheck ? true, doHaddock ? false, jailbreak ? false}:
    let
      extraConfFlags = pkgs.lib.concatLists (pkgs.lib.mapAttrsToList (lname: drv': mkCabalConfFlags lname drv') extraLibs);
    in
    pkgs.haskell.lib.overrideCabal
    drv
    (_drv: {
      inherit doCheck doHaddock jailbreak;

      isLibrary = false;
      isExecutable = true;
      enableSharedExecutables = false;
      enableSharedLibraries = false;
      configureFlags = [
        "--ghc-option=-split-sections"
        "--ghc-option=-optl=-static"
        "--ghc-option=-optl=-lbz2"
        "--ghc-option=-optl=-lz"
        "--ghc-option=-optl=-lelf"
        "--ghc-option=-optl=-llzma"
        "--ghc-option=-optl=-lzstd"
        "--ghc-option=-optl=-lyaml"
        "--ghc-option=-optl=-lffi"
        "--extra-lib-dirs=${pkgs.glibc.static}/lib"
        "--extra-lib-dirs=${pkgs.gmp6.override {withStatic = true;}}/lib"
        "--extra-lib-dirs=${pkgs.zlib.static}/lib"
        "--extra-lib-dirs=${(pkgs.xz.override {enableStatic = true;}).out}/lib"
        "--extra-lib-dirs=${(pkgs.zstd.override {enableStatic = true;}).out}/lib"
        "--extra-lib-dirs=${(pkgs.bzip2.override {enableStatic = true;}).out}/lib"
        "--extra-lib-dirs=${(pkgs.elfutils.overrideAttrs (old: {dontDisableStatic = true;})).out}/lib"
        "--extra-lib-dirs=${pkgs.libffi.overrideAttrs (old: {dontDisableStatic = true;})}/lib"
        "--extra-lib-dirs=${(pkgs.libyaml.overrideAttrs (old: {dontDisableStatic = true;})).out}/lib"
        "--extra-lib-dirs=${(pkgs.libffi.overrideAttrs (old: {dontDisableStatic = true;})).out}/lib"
      ] ++ extraConfFlags;
    });

  # Make the name used for the static builds.
  # lname: the name passed to the linker to find the library.
  # drv: the derivation corresponding to 'lname' that should be converted to
  #      be built statically and passed to cabal.
  mkCabalConfFlags = lname: drv: [
    "--ghc-option=-optl=-${lname}"
    ( if drv ? static then
        "--extra-lib-dirs=${drv.static}/lib"
     else if drv.override.__functionArgs ? withStatic then
       "--extra-lib-dirs=${drv.override {withStatic = true;}}/lib"
     else if drv.override.__functionArgs ? enableStatic then
        "--extra-lib-dirs=${(drv.override {enableStatic = true;}).out}/lib"
     else
        "--extra-lib-dirs=${(drv.overrideAttrs (old: {dontDisableStatic = true;})).out}/lib"
    )
    ];
}
