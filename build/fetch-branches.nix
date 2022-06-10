{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "fetch-branches.sh"
  ''
  set -e

  HASHES=$(git ls-remote git@github.com:NixOS/nixpkgs.git)
  
  while read BRANCH; do
    HASH=$(grep "refs/heads/''${BRANCH}$" <<< $HASHES | cut -f1 )
    SUMMARY=$(${pkgs.nix-prefetch-git}/bin/nix-prefetch-git git@github.com:NixOS/nixpkgs.git --quiet --rev $HASH)
    echo $(${pkgs.jq}/bin/jq --arg BRANCH ''${BRANCH} '. + { branch: ($BRANCH) }' <<< $SUMMARY )
  done <${./channels.txt} | ${pkgs.jq}/bin/jq -n '.branches |= [inputs]' > ../branches.json
  ''


# TODO: It would be really nice if we could evaluate this with
# nix. The problem is that `git` `nix-prefetch-git` are impure.
#  
# I should look into how `pkgs.fetchGit` works.
#
# pkgs.stdenv.mkDerivation {
#   name = "branches.json";
#   unpackPhase = "true";
#   installPhase = pkgs.writeShellScript "fetch-branches.sh" ''
#   set -e
# 
#   HASHES=$(${pkgs.git}/bin/git ls-remote git@github.com:NixOS/nixpkgs.git)
#   
#   while read BRANCH; do
#     HASH=$(grep "refs/heads/''${BRANCH}$" <<< $HASHES | cut -f1 )
#     SUMMARY=$(${pkgs.nix-prefetch-git}/bin/nix-prefetch-git git@github.com:NixOS/nixpkgs.git --quiet --rev $HASH)
#     echo $(${pkgs.jq}/bin/jq --arg BRANCH ''${BRANCH} '. + { branch: ($BRANCH) }' <<< $SUMMARY )
