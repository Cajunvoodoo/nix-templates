{
  description = "Cajun's collection of flake templates";

  inputs = {};

  outputs = { self }: {
    templates = {
      haskell-overkill = {
        path = builtins.path {path = ./haskell-overkill; name = "haskell-overkill-template";};
        description = "Batteries-included Haskell flake";
        welcomeText = ''
          Cajun's Haskell flake template (Overkill edition).
          Remember to:
          - Accept the cachix flake config
          - Change 'pname' to the name of your cabal project
          - Change 'buildProject' to true
          - Change the Github actions builder as appropriate
          - Change the use of my public cache as appropriate
        '';
      };

      haskell = {
        path = builtins.path {path = ./haskell; name = "haskell-template";};
        description = "Batteries-included Haskell flake";
        welcomeText = ''
          Cajun's Haskell flake template.
          Remember to:
          - Change 'pname' to the name of your cabal project
          - Change 'buildProject' to true
          - Change the Github actions builder as appropriate
        '';
      };

      haskell-simple = {
        path = builtins.path {path = ./haskell-simple; name = "haskell-simple-template";};
        description = "Minimal Haskell flake";
      };

      C = {
        path = builtins.path {path =  ./C; name = "C-template";};
        description = "Simple makefile-based C template";
      };

      devshell = {
        path = builtins.path {path = ./devshell; name = "devshell-template";};
        description = "Bare flake outputting only a devshell";
      };

      zig = {
        path = builtins.path {path = ./zig; name = "zig-template";};
        description = "Zig flake template with ZLS and Pwndbg";
      };
    };
  };
}
