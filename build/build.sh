set -e

fetchBranches=$(nix-build fetch-branches.nix)

echo $fetchBranches
echo "Fetching Nixpkgs Branches..."

eval $fetchBranches

echo "Fetching Nixpgs Branches Complete"

echo "Fetching GHC Compilers"
compilers=$(nix-build fetch-compilers.nix)

if [ -f ../compilers.json ];
then rm ../compilers.json
fi

cp $compilers ../compilers.json
chmod +770 ../compilers.json
