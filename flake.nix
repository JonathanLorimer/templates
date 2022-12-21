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
      packages.init = import ./init.nix { pkgs = pkgs; };

      apps = rec {
        init = utils.mkApp {
          name = "init";
          drv = packages.init;
        };
        default = init;
      };
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
          description = "A template for a haskell project that uses flakes";
          welcomeText = ''
            You just created a haskell flake project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        idris = {
          path = ./template/idris;
          description = "A template for an idris2 project";
          welcomeText = ''
            You just created an idris2 project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        rust = {
          path = ./template/rust;
          description = "A template for a rust project";
          welcomeText = ''
            You just created a rust project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        agda = {
          path = ./template/agda;
          description = "A template for an agda project";
          welcomeText = ''
            You just created an agda project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
        flake = {
          path = ./template/flake;
          description = "A template for a generic flake project";
          welcomeText = ''
            You just created a flake project.
            run this command to add your projects name:
              nix run github:JonathanLorimer/templates
          '';
        };
      };

      defaultTemplate = self.templates.haskell;
    };
}
