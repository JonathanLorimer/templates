{
  description = "__package_name";

  inputs = {
    # Nix Inputs
    nixpkgs.url = github:nixos/nixpkgs/__nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
  }: let
    utils = flake-utils.lib;
  in
    utils.eachDefaultSystem (system: let
      compilerVersion = "__ghcVersion";
      pkgs = nixpkgs.legacyPackages.${system};
      hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
        overrides = hfinal: hprev: {
          __package_name = hfinal.callCabal2nix "__package_name" ./. {};
        };
      };
    in {
      # nix build
      packages =
        utils.flattenTree
        {
          __package_name = hsPkgs.__package_name;
          default = self.packages.${system}.__package_name;
        };

      # nix flake check
      checks = {
        __package_name = self.packages.${system}.__package_name;
      };

      # nix develop
      devShell = hsPkgs.shellFor {
        withHoogle = true;
        packages = p: [
          p.__package_name
        ];
        buildInputs = with pkgs;
          [
            hsPkgs.haskell-language-server
            haskellPackages.cabal-install
            cabal2nix
            haskellPackages.ghcid
            haskellPackages.fourmolu
            haskellPackages.cabal-fmt
            nodePackages.serve
          ]
          ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
      };

      # nix run
      apps = {
        __package_name = utils.mkApp {
          drv = self.packages.${system}.default;
        };

        default = self.apps.${system}.__package_name;
      };
    });
}
