{ inputs, pkgs, ... }:
{
  ### wsl int
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = "nuko";
    wslConf.user.default = "nuko";
    useWindowsDriver = true;
    usbip.enable = true;
    startMenuLaunchers = true;
  };
  mods = {
    misc = {
      nix = {
        config = true;
        flakePath = "/home/nuko/crystal";
        nh = true;
      };
      cleanDefaults = true;
      nztz = true;
    };
    user.main.shell.setup = true;
    programs = {
      neovim = true;
      git = true;
    };
  };
  # wsl doesnt seem happy with me taking uid 1000? and we arent using agenix here either cause lazy..
  # soooo new user def..
  users = {
    mutableUsers = false;
    users.main = {
      hashedPassword = "$y$j9T$9CtCHeGALxxXBPyMXMgey0$/JZcbnVI78ScTlGtn.P1BAnRGreo8WsXG1Yr4dj7JM2";
      uid = 1001;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      name = "nuko";
      packages = builtins.attrValues { inherit (pkgs) wget yazi; };
    };
  };
  security.sudo.execWheelOnly = true;
  networking.hostName = "portal";
  ### dont be silly
  system.stateVersion = "23.11";
}
