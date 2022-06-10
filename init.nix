{ pkgs }:

pkgs.writeShellScriptBin "init"
  ''
  set -e
  
  CHANNEL=$(${pkgs.fzf}/bin/fzf --header-first --header 'Choose a Nixpkgs release' < ${./channels.txt})
  
  ${pkgs.ruplacer}/bin/ruplacer __nixpkgs "$CHANNEL" --go
  
  echo "What do you want this package to be called? "
  read -p '> ' -r name
  
  if [ -f ./template.cabal ]; then
    mv ./template.cabal "./$name.cabal"
    fi
    
    if [ -f ./template.ipkg ]; then
      mv ./template.ipkg "./$name.ipkg"
      fi
      
      ${pkgs.ruplacer}/bin/ruplacer __package_name "$name" --go
  ''
