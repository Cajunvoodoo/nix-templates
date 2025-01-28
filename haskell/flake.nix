{
  description = "Description for the project";

  # Binary server configuration
  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = "https://nix-cache.cajun.page/public https://pre-commit-hooks.cachix.org";
    extra-trusted-public-keys = "public:Ts+1e+F/BjkLKF/7eqbHa7x/wKWXA5PzU8bVRBy0ysU= pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc=";
    # netrc-file = ./netrc; # Use if cache is private
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }: let
    pname = "PROJ_NAME"; # Your cabal project's name
    buildProject = false; # Include your project (useful for cabal init)
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        system,
        self',
        ...
      }: let
        # Contains utilities for making static binaries.
        utils = import ./utils.nix {inherit pkgs;};
        hsSrc = dir: with pkgs.lib.fileset; toSource {
          root = dir;
          fileset =
            intersection
              (gitTracked dir)
              (unions [
                (fileFilter (file: file.hasExt "hs") dir)
                (fileFilter (file: file.hasExt "hsc") dir)
                (fileFilter (file: file.hasExt "cabal") dir)
                (fileFilter (file: file.hasExt "md") dir)
                (fileFilter (file: file.name == "LICENSE") dir)
              ]);
        };
        hp =
          if buildProject
          then
            pkgs.haskellPackages.override {
              overrides = final: prev: {
                ${pname} = final.callCabal2nix pname (hsSrc ./.) {};
              };
            }
          else pkgs.haskellPackages;
      in {
        ########################################################################
        ##                       PRIMARY CONFIGURATION                        ##
        ########################################################################
        formatter = pkgs.alejandra;

        packages.default =
          if buildProject
          then hp.${pname}
          else pkgs.hello;

        devShells.default = hp.shellFor {
          packages = hpkgs:
            with hpkgs; (
              if buildProject
              then [self'.packages.default]
              else []
            );
          nativeBuildInputs = with hp; with pkgs; [
            cabal-fmt
            cabal-install
            fourmolu
            haskell-language-server
          ];
          shellHook = ''
            echo 1>&2 "Welcome to the development shell!"
          '';
        };

        ########################################################################
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
}
