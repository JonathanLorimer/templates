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
          # Needed for hls on ghc 9.2.5 and 9.4.3
          # https://github.com/ddssff/listlike/issues/23
          ListLike = pkgs.haskell.lib.dontCheck hprev.ListLike;
        };
      };
    in {
      # nix build
      packages =
        utils.flattenTree
        {
          __package_name = hsPkgs.__package_name;
          default = hsPkgs.__package_name;
        };

      # You can't build the __package_name package as a check because of IFD in cabal2nix
      checks = {};

      # nix fmt
      formatter = pkgs.alejandra;

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
      apps = let
        __package_name = utils.mkApp {
          drv = self.packages.${system}.default;
        };
      in {
        inherit __package_name;
        default = __package_name;
      };
    });
}
