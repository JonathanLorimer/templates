{
  description = "__package_name";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/__nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
    cornelis.url = github:isovector/cornelis;
  };

  outputs = inputs:
    with inputs.flake-utils.lib;
    eachDefaultSystem (system:

    let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      utils = inputs.flake-utils.lib;
      cornelis = inputs.cornelis.packages.${system}.cornelis;
    in
      {
        # nix develop
        devShell =
          pkgs.mkShell {
            buildInputs = with pkgs; [
              cornelis
              (agda.withPackages (ps: [
                ps.standard-library
                ])
              )
            ];
          };
      });
}
