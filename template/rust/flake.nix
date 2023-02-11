{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/__nixpkgs;
    crane.url = github:ipetkov/crane;
    pre-commit-hooks.url = github:cachix/pre-commit-hooks.nix;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = {
    nixpkgs,
    crane,
    pre-commit-hooks,
    flake-utils,
    self,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      craneLib = crane.lib.${system};
      src = ./.;
      cargoArtifacts = craneLib.buildDepsOnly {
        inherit src;
      };
      __package_name-clippy = craneLib.cargoClippy {
        inherit cargoArtifacts src;
        cargoClippyExtraArgs = "-- --deny warnings";
      };
      __package_name = craneLib.buildPackage {
        inherit cargoArtifacts src;
        nativeBuildInputs = with pkgs; [
        ];
      };
      __package_name-coverage = craneLib.cargoTarpaulin {
        inherit cargoArtifacts src;
      };
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          nix-linter.enable = true;
          rustfmt.enable = true;
        };
      };
    in {
      defaultPackage = __package_name;
      checks = {
        inherit
          # Build the crate as part of `nix flake check` for convenience
          __package_name
          __package_name-clippy
          __package_name-coverage
          pre-commit-check
          ;
      };
      devShells.default = pkgs.mkShell {
        shellHook = self.checks.${system}.pre-commit-check.shellHook;
        buildInputs = with pkgs; [
          rust-analyzer
          rnix-lsp
          rustc
          cargo
        ];
      };
    });
}
