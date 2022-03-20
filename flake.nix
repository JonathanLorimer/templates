{
  description = "Multiformats in haskell";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    let utils = flake-utils.lib;
    in
    utils.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      templates = {
        haskell-flake = {
          path = ./template;
          description = "A template that for a haskell project that uses flakes";
          welcomeText = ''
            You just created a haskell flake project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/haskell-flake-template
          '';
        };
      };

      defaultTemplate = self.templates.haskell-flake;

      packages.init =
        pkgs.writeShellApplication {
          name = "init";
          name = "launcher";
          text = (builtins.readFile ./init.sh);
          runtimeInputs = with pkgs; [ ruplacer ];
        };

      apps.init = mkApp { name = "init"; drv = self.packages.init; };
      defaultApp = self.apps.init;
    });
}
