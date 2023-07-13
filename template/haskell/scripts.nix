{s}: 
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:__package_name' --allow-eval --warnings";
  testScript = s "test" "cabal run test:__package_name-tests";
  hoogleScript = s "hgl" "hoogle serve";
}
