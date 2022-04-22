set -e

echo "What do you want this package to be called? "
read -r name

if [ -f ./template.cabal ]; then
  mv ./template.cabal "./$name.cabal"
fi

if [ -f ./template.ipkg ]; then
  mv ./template.ipkg "./$name.ipkg"
fi

ruplacer __package_name "$name" --go
