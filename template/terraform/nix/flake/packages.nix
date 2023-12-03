{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages = with inputs.nixpkgs.lib;
      lists.foldl recursiveUpdate
      {}
      [
        (import ../packages/scripts.nix {inherit pkgs;})
      ];
  };
}
