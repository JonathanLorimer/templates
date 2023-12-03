{
  withSystem,
  inputs,
  ...
}: let
  mkConfig = cfgPath:
    withSystem "x86_64-linux" ({
      config,
      inputs',
      ...
    }:
      inputs.nixpkgs.lib.nixosSystem {
        # Expose `packages`, `inputs` and `inputs'` as module arguments.
        # Use specialArgs permits use in `imports`.
        # Note: if you publish modules for reuse, do not rely on specialArgs, but
        # on the flake scope instead. See also https://flake.parts/define-module-in-separate-file.html
        specialArgs = {
          packages = config.packages;
          inherit inputs inputs';
        };
        system = "x86_64-linux";
        modules = [cfgPath];
      });
in {
  flake.nixosConfigurations = {
    sample-server = mkConfig ../configurations/sample-server;
  };
}
