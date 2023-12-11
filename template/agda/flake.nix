{
  description = "__package_name";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cornelis.url = "github:isovector/cornelis";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    cornelis,
  }:
    with flake-utils.lib;
    eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
      {
        # nix develop
        devShell =
          pkgs.mkShell {
            buildInputs = [
              cornelis.packages.${system}.cornelis
              cornelis.packages.${system}.agda
            ];
          };
      });
}
