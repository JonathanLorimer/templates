{ s }:
rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:__package_name' --allow-eval --warnings";
  allScripts = [ ghcidScript ];
}
