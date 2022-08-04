{ pkgs }:

pkgs.writeShellScriptBin "init"
  ''
  set -e

  echo "What do you want this package to be called? "
  read -p '> ' -r name

  BRANCH=$(
    ${pkgs.curl}/bin/curl -s https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision |\
    ${pkgs.jq}/bin/jq '.data.result[].metric.channel' |\
    ${pkgs.gnused}/bin/sed -e 's/^"//' -e 's/"$//' |\
    ${pkgs.fzf}/bin/fzf --header-first --header 'Choose a Nixpkgs release'
  )

  ${pkgs.ruplacer}/bin/ruplacer __nixpkgs "$BRANCH" --go

  if [ -f ./template.cabal ]; then
    mv ./template.cabal "./$name.cabal"

    GHCVERSION=$(
      ${pkgs.curl}/bin/curl -s "https://github.com/NixOS/nixpkgs/tree/$BRANCH/pkgs/development/compilers/ghc" |\
      ${pkgs.pup}/bin/pup '.js-navigation-open.Link--primary:contains(".nix") text{}' |\
      ${pkgs.sd}/bin/sd '(\d{1,2}).(\d{1,2}).(\d{1,2}).nix' 'ghc$1$2$3' |\
      ${pkgs.gawk}/bin/awk '/ghc/{print}' |\
      ${pkgs.fzf}/bin/fzf --header-first --header 'Choose a version of GHC'
    )

    echo $GHCVERSION

    ${pkgs.ruplacer}/bin/ruplacer __ghcVersion "$GHCVERSION" --go

  fi

  if [ -f ./template.ipkg ]; then
    mv ./template.ipkg "./$name.ipkg"
  fi

  if [ -f ./template.agda-lib ]; then
    mv ./template.agda-lib "./$name.agda-lib"
  fi

  ${pkgs.ruplacer}/bin/ruplacer __package_name "$name" --go

  ${pkgs.git}/bin/git init
  ${pkgs.git}/bin/git add .
  ${pkgs.git}/bin/git branch -m main
  ''
