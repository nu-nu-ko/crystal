{
  lib,
  config,
  pkgs,
  ...
}: {
  options.local.misc.root.disable = lib.mkEnableOption "";
  config = lib.mkIf config.local.misc.root.disable {
    users.users.root = {
      hashedPassword = "!"; # wont eval
      shell = pkgs.shadow; # more informative than just no password
      home = lib.mkForce "/home/root"; # for sudo
    };
  };
}
