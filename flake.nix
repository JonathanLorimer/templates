{
  description = "A flake template for haskell flake projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    utils = flake-utils.lib;
  in
    utils.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      packages.init = pkgs.writeShellApplication {
        name = "init";
        text = builtins.readFile ./init.sh;
        runtimeInputs = with pkgs; [ruplacer];
      };

      apps.init = utils.mkApp {
        name = "init";
        drv = packages.init;
      };
      defaultApp = apps.init;
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          rnix-lsp
          alejandra
        ];
      };
    })
    // {
      templates = {
        haskell = {
          path = ./template/haskell;
          description = "A template that for a haskell project that uses flakes";
          welcomeText = ''
            You just created a haskell flake project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        idris = {
          path = ./template/idris;
          description = "A template that for an idris2 project";
          welcomeText = ''
            You just created an idris2 project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        rust = {
          path = ./template/rust;
          description = "A template that for a rust project";
          welcomeText = ''
            You just created a rust project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
      };

      defaultTemplate = self.templates.haskell-flake;
    };
}
