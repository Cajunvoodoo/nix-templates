{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }: let
    pname = "PROJ_NAME";  # Your cabal project's name
    buildProject = false; # Whether to build your project (useful for cabal init)
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { pkgs, system, self',... }:
        let
          hp =
            if buildProject then
              pkgs.haskellPackages.override {
                overrides = final: prev: {
                  ${pname} = final.callCabal2nix pname ./. {};
                };
              }
            else pkgs.haskellPackages;
        in {

        formatter = pkgs.nixfmt;

        packages.default = hp.${pname};

        devShells.default = hp.shellFor {
          packages = hpkgs: with hpkgs;
            (if buildProject then [self'.packages.default] else []);
          nativeBuildInputs = with hp; with pkgs; [
            cabal-install
          ];
        };


        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
}
