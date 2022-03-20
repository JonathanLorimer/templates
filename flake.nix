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
      pkgs = import nixpkgs { inherit system; };
    in
    rec {
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

      defaultTemplate = templates.haskell-flake;

      packages.init =
        pkgs.writeShellApplication {
          name = "init";
          text = (builtins.readFile ./init.sh);
          runtimeInputs = with pkgs; [ ruplacer ];
        };

      apps.init = utils.mkApp { name = "init"; drv = packages.init; };
      defaultApp = apps.init;
    });
}
