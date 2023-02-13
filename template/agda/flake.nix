{
  description = "__package_name";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    # Pinned while main is broken
    cornelis.url = github:isovector/cornelis/7b72d947cf9be5119868bb833db8141cad02235e;
  };

  outputs = {
    self,
    flake-utils,
    cornelis,
  }:
    with flake-utils.lib;
    eachDefaultSystem (system:

    let
      utils = flake-utils.lib;
      cornelis = cornelis.packages.${system}.cornelis;
      agda = cornelis.packages.${system}.agda;
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
