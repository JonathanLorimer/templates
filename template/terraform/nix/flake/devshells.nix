{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      config.allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "terraform"
        ];
    };

    # development environments
    devShells.default = pkgs.mkShell {
      name = "__package_name-devshell";
      buildInputs = with pkgs; [
        awscli2
        sops
        terraform
        terraform-ls
        yq
        jq
      ];
    };
  };
}
