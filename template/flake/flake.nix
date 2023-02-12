{
  description = "__package_name";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/__nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = inputs:
    with inputs.flake-utils.lib;
      eachDefaultSystem (system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
        };
        utils = inputs.flake-utils.lib;
      in {
        # nix develop
        devShell =
          pkgs.mkShell {};
      });
}
