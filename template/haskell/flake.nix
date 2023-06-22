{
  description = "__package_name";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/__nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: 
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function rec {
          inherit system;
          compilerVersion = "__ghcVersion";
          pkgs = nixpkgs.legacyPackages.${system};
          hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
            overrides = hfinal: hprev: {
              __package_name = hfinal.callCabal2nix "__package_name" ./. {};
            };
          };
        });
    in
    {
      # nix fmt
      formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

      # nix develop
      devShell = forAllSystems ({hsPkgs, pkgs, ...}:
        hsPkgs.shellFor {
          # withHoogle = true;
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
            ]
            ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
        });

      # nix build
      packages = forAllSystems ({hsPkgs, ...}: {
          __package_name = hsPkgs.__package_name;
          default = hsPkgs.__package_name;
      });

      # You can't build the __package_name package as a check because of IFD in cabal2nix
      checks = {};

      # nix run
      apps = forAllSystems ({system, ...}: {
        __package_name = { 
          type = "app"; 
          program = "${self.packages.${system}.__package_name}/bin/__package_name"; 
        };
        default = self.apps.${system}.__package_name;
      });
    };
}
