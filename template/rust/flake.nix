{
  inputs = {
    nci.url = "github:yusdacra/nix-cargo-integration";
  };
  outputs = {
    nci,
    self
  }: nci.lib.makeOutputs {
    root = ./.;
    enablePreCommitHooks = true;
  };
}
