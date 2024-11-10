{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { pkgs, system, ... }: {
        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          name = "Cxx-devshell";
          packages = with pkgs; [    # Executables to include in the devshell
            stdenv.cc
          ];
          inputsFrom = [];           # Include these derivations' dependencies
          shellHook = "";            # The shellhook to run
        };

        packages.default = pkgs.mkDerivation {
          pname = "PROJECT_NAME";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            gnumake
          ];

          buildInputs = with pkgs; [
          ];

          # cmakeFlags = [
          #   "-DENABLE_TESTING=OFF"
          #   "-DENABLE_INSTALL=ON"
          # ];

        };
      };
    };
}
