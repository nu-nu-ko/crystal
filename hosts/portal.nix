{ inputs, pkgs, ... }:
let
  name = "nuko";
in
{
  ### wsl int
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = name;
    wslConf.user.default = name;
    useWindowsDriver = true;
    usbip.enable = true;
    startMenuLaunchers = true;
  };
  _common = {
    nix = {
      config = true;
      flakePath = "/home/${name}/crystal";
      nh = true;
    };
    cleanup = true;
  };
  _system.timeZone.NZ = true;
  _user.mainUser.shell.setup = true;
  _programs = {
    neovim = true;
    git = true;
  };
  # wsl doesnt seem happy with me taking uid 1000? and we arent using agenix here either cause lazy..
  # soooo new user def..
  users = {
    mutableUsers = false;
    users.main = {
      inherit name;
      hashedPassword = "$y$j9T$9CtCHeGALxxXBPyMXMgey0$/JZcbnVI78ScTlGtn.P1BAnRGreo8WsXG1Yr4dj7JM2";
      uid = 1001;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      packages = builtins.attrValues { inherit (pkgs) wget yazi; };
    };
  };
  security.sudo.execWheelOnly = true;
  networking.hostName = "portal";
  ### dont be silly
  system.stateVersion = "23.11";
}
