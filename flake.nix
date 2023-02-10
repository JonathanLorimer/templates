{
  description = "A flake template for haskell flake projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    rustOverlay.url = "github:oxalica/rust-overlay";
    devshell.url = "github:numtide/devshell";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    crane,
    rustOverlay,
    devshell,
  }: let
    utils = flake-utils.lib;
  in
    utils.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import rustOverlay)
          devshell.overlay
        ];
      };

      rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
        toolchain.default.override {
          extensions = ["rust-src"];
        });
    in rec {
      packages.init = import ./init.nix { pkgs = pkgs; };

      apps = rec {
        init = utils.mkApp {
          name = "init";
          drv = packages.init;
        };
        default = init;
      };
      devShells.default = pkgs.devshell.mkShell {
        commands = let
          categories = {
            hygiene = "hygiene";
          };
        in [
          {
            help = "Check rustc and clippy warnings";
            name = "check";
            command = ''
              set -x
              cargo check --all-targets
              cargo clippy --all-targets
            '';
            category = categories.hygiene;
          }
          {
            help = "Automatically fix rustc and clippy warnings";
            name = "fix";
            command = ''
              set -x
              cargo fix --all-targets --allow-dirty --allow-staged
              cargo clippy --all-targets --fix --allow-dirty --allow-staged
            '';
            category = categories.hygiene;
          }
        ];
        imports = ["${devshell}/extra/language/rust.nix"];
        language.rust = {
          packageSet = rustToolchain;
          tools = ["rustc"];
          enableDefaultToolchain = false;
        };

        devshell = {
          name = "templates-devshell";
          packages = with pkgs;
            [
              # Rust build inputs
              clang
              coreutils

              # LSP's
              rust-analyzer

              # Tools
              rustToolchain
              alejandra
            ];
        };
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
      };

      defaultTemplate = self.templates.haskell;
    };
}
