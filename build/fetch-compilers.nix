{ pkgs ? import <nixpkgs> { } }:

let
  branches = builtins.fromJSON (builtins.readFile ./branches.json);
  json = builtins.toJSON (builtins.foldl' (xs: {rev, sha256, branch, ...}:
    let filterPredicate = x: (builtins.isNull (builtins.match ".*Binary.*" x)) &&
                             !(builtins.any (y: y == x) ["native-bignum" "integer-simple"]);
        versions = builtins.filter filterPredicate (builtins.attrNames (import (pkgs.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = rev;
          sha256 = sha256;
        }) { }).haskell.compiler);
    in { "${branch}" = { inherit sha256; inherit rev; "ghc" = versions; };} // xs) { } branches);
  jsonDrv = pkgs.writeText "compilers.json" json;
in
pkgs.stdenv.mkDerivation {
  name = "compilers.json";
  unpackPhase = "true";
  installPhase = ''
    cat ${jsonDrv} | ${pkgs.jq}/bin/jq > $out
  '';
}
