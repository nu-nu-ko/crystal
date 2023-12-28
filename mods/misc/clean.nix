{
  lib,
  config,
  ...
}: {
  options.local.misc.clean.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.misc.clean.enable {
    programs = {
      # i dont need more than one editor thank you
      nano.enable = lib.mkForce false;
      # prob fine i just dont care for it
      command-not-found.enable = lib.mkForce false;
    };
    environment = {
      # either unwanted or included in more apropreate places.
      defaultPackages = lib.mkForce [];
      # unsure if this borks xwayland/apps that only support X just yet.
      noXlibs = lib.mkForce false;
    };
    # only removed cause i just use online docs
    documentation = {
      enable = lib.mkForce false;
      doc.enable = lib.mkForce false;
      info.enable = lib.mkForce false;
      man.enable = lib.mkForce false;
      nixos.enable = lib.mkForce false;
    };
    # claims to be of no cost to leave enabled, but whatever xD
    boot.enableContainers = lib.mkForce false;
  };
}
