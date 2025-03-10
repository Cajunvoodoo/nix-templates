{
  description = "Cajun's collection of flake templates";

  inputs = {};

  outputs = { self }: {
    templates = {
      haskell-overkill = {
        path = ./haskell-overkill;
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
        path = ./haskell;
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
        path = ./haskell-simple;
        description = "Minimal Haskell flake";
      };

      C = {
        path = ./C;
        description = "Simple makefile-based C template";
      };

      devshell = {
        path = ./devshell;
        description = "Bare flake outputting only a devshell";
      };
    };
  };
}
