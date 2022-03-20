set -e

echo "What do you want this haskell package to be called? "
read -r name

mv ./template.cabal "./$name.cabal"

ruplacer __package_name "$name"
