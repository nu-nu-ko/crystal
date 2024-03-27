{
  config,
  _lib,
  lib,
  ...
}:
{
  options._programs.ssh = _lib.mkEnable;
  config.programs.ssh = lib.mkIf config._programs.ssh {
    knownHosts = {
      library = {
        extraHostNames = [
          "tea.shimeji.cafe"
          "192.168.0.3"
          "119.224.63.166"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+1CxNCNvstjiRJFgJHVgqb/Mm1MJZOSoahwzgGXHMH";
      };
      factory = {
        extraHostNames = [ "192.168.0.4" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLJR5DDyMYyKoUaZDML29f1AEJZ98nfizrdJ8jCLP6h";
      };
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
