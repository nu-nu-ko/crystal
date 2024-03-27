{
  config,
  _lib,
  lib,
  ...
}:
{
  options._programs.git = _lib.mkEnable;
  config.programs.git = lib.mkIf config._programs.ssh {
    enable = true;
    config = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      user = {
        inherit (config.users.users.main) name;
        email = "${config.users.users.main.name}@shimeji.cafe";
        signingkey = "/home/${config.users.users.main.name}/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };
}
