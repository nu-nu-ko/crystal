{
  pkgs,
  lib,
  nuke,
  config,
  inputs,
  ...
}:
let
  inherit (nuke) mkEnable;
  inherit (lib) mkIf mkOption optionals;
  inherit (lib.types) str;
  inherit (inputs) nixpkgs agenix;
  inherit (config.mods.misc)
    secrets
    cleanDefaults
    nztz
    nix
    wired
    hostKey
    ;
in
{

  imports = [ agenix.nixosModules.default ];

  options.mods.misc = {
    secrets = mkEnable;
    cleanDefaults = mkEnable;
    nztz = mkEnable;
    hostKey = mkEnable;
    nix = {
      config = mkEnable;
      nh = mkEnable;
      flakePath = mkOption {
        type = str;
        default = "/storage/Repos/crystal";
      };
    };
    wired = {
      enable = mkEnable;
      ip = mkOption { type = str; };
      card = mkOption { type = str; };
    };
  };
  config = {
    ### wired
    networking = mkIf wired.enable {
      enableIPv6 = false;
      useDHCP = false;
    };
    systemd.network = mkIf wired.enable {
      enable = true;
      networks.${wired.card} = {
        enable = true;
        name = wired.card;
        networkConfig = {
          DHCP = "no";
          DNSSEC = "yes";
          DNSOverTLS = "yes";
          DNS = [
            "1.1.1.1"
            "1.1.0.0"
          ];
        };
        address = [ "${wired.ip}/24" ];
        routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
      };
    };
    ### hostkey setup
    services.openssh.hostKeys = mkIf hostKey [
      {
        comment = "${config.networking.hostName} host";
        path = "/etc/ssh/${config.networking.hostName}_ed25519_key";
        type = "ed25519";
      }
    ];
    ### secrets setup
    environment.systemPackages = mkIf secrets [ agenix.packages.${pkgs.system}.default ];
    age.identityPaths = mkIf secrets [ "/home/${config.users.users.main.name}/.ssh/id_ed25519" ];
    ### clean
    programs = mkIf cleanDefaults {
      nano.enable = false;
      command-not-found.enable = false;
      bash.enableCompletion = false;
    };
    xdg.sounds.enable = mkIf cleanDefaults false;
    environment.defaultPackages = mkIf cleanDefaults [ ];
    documentation = mkIf cleanDefaults {
      enable = false;
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
    };
    boot.enableContainers = mkIf cleanDefaults false;
    ### timezone
    time.timeZone = mkIf nztz "NZ";
    i18n.defaultLocale = mkIf nztz "en_NZ.UTF-8";
    ### nix
    nix = mkIf nix.config {
      settings = {
        experimental-features = [
          "auto-allocate-uids"
          "no-url-literals"
          "nix-command"
          "flakes"
        ];
        auto-allocate-uids = true;
        auto-optimise-store = true;
        allowed-users = [ "@wheel" ];
        use-xdg-base-directories = true;
        nix-path = [ "nixpkgs=flake:nixpkgs" ];
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
      registry.nixpkgs.flake = nixpkgs;
      channel.enable = false;
    };
    nixpkgs = {
      hostPlatform = "x86_64-linux";
      config.allowUnfree = true;
    };
    environment = {
      etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
      sessionVariables.FLAKE = nix.flakePath;
    };
    users.users.main.packages = optionals (nix.nh) [ pkgs.nh ];
  };
}
