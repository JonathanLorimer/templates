{
  pkgs,
  inputs,
  ...
}: let
  inherit (import ./nixpkgs/caches.nix) substituters trusted-public-keys;
  nixpkgs = inputs.nixpkgs;
in {
  nix = {
    package = pkgs.nixFlakes;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      inherit substituters trusted-public-keys;
    };

    nixPath = [
      "nixpkgs=${nixpkgs}"
    ];

    registry = {
      nixpkgs.flake = nixpkgs;
    };
  };
}
