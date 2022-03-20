set -e

read -p "What do you want this haskell package to be called? " name

mv ./template.cabal "./$name.cabal"

ruplacer __package_name $name
