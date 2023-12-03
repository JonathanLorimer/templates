({
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (inputs.nixpkgs + "/nixos/modules/virtualisation/amazon-image.nix")
    (inputs.nixpkgs + "/nixos/maintainers/scripts/ec2/amazon-image.nix")
    {amazonImage.sizeMB = 4096;}
    ../modules/nix.nix
    ../modules/users.nix
    ../modules/openssh.nix
  ];
  environment.systemPackages = with pkgs; [
    vim
    htop
    postgresql_16
  ];
})
