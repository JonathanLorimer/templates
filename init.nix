{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "init"
  ''
  set -e

  echo "What do you want this package to be called? "
  read -p '> ' -r name
  
  BRANCH=$(${pkgs.fzf}/bin/fzf --header-first --header 'Choose a Nixpkgs release' < ${./channels.txt})
  
  ${pkgs.ruplacer}/bin/ruplacer __nixpkgs "$BRANCH" --go
  
  if [ -f ./template.cabal ]; then
    mv ./template.cabal "./$name.cabal"

    GHCVERSIONS=$(${pkgs.jq}/bin/jq --arg BRANCH ''${BRANCH} '.[($BRANCH)].ghc | join(" ")' < ${./compilers.json} | tr -d '"' | tr ' ' '\n' )
    GHCVERSION=$(${pkgs.fzf}/bin/fzf --header-first --header 'Choose a GHC version' <<< $GHCVERSIONS)
    
    ${pkgs.ruplacer}/bin/ruplacer __ghcVersion "$GHCVERSION" --go

    fi
    
    if [ -f ./template.ipkg ]; then
      mv ./template.ipkg "./$name.ipkg"
      fi
      
      ${pkgs.ruplacer}/bin/ruplacer __package_name "$name" --go

  ${pkgs.git}/bin/git init
  ${pkgs.git}/bin/git add .
  ${pkgs.git}/bin/git branch -m main
  ''
