{
  description = "__package_name";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];
      imports = [
        ./nix/flake
      ];
    };

  inputs = {
    # package sets
    nixpkgs.url = "github:nixos/nixpkgs/__nixpkgs";
    # flake module management
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
