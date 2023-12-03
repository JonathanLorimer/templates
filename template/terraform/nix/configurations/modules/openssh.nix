{lib, ...}: {
  services.openssh = {
    enable = true;
    allowSFTP = lib.mkDefault false;

    # Stealing some "paranoid" OpenSSH configuration options.
    #
    # cf. https://christine.website/blog/paranoid-nixos-2021-07-18
    settings = {
      AllowAgentForwarding = true;
      AllowStreamLocalForwarding = false;
      AllowTcpForwarding = true;
      AuthenticationMethods = "publickey";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };
}
