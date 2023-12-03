{pkgs, ...}: let
  mkUser = {
    name,
    key,
    keys ? [],
    shell ? pkgs.bashInteractive,
  }: {
    users.users."${name}" = {
      inherit shell;
      extraGroups = ["wheel" "users"];
      openssh.authorizedKeys.keys =
        if key != null
        then [key] ++ keys
        else keys;
      isNormalUser = true;
    };
  };

  users = [
    {
      name = "sample-user";
      key = "pubkey";
      shell = pkgs.zsh;
    }
  ];
in {
  imports = map mkUser users;

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "*";
    };
  };

  nix.settings.trusted-users = ["@wheel"];

  programs.zsh.enable = true;
}
