{
  inputs,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  imports = [ inputs.agenix.nixosModules.default ];
  options._common =
    let
      inherit (_lib) mkEnable;
      inherit (lib) mkOption types;
      inherit (types) str;
    in
    {
      agenix.setup = mkEnable;
      cleanup = mkEnable;
      nix = {
        config = mkEnable;
        nh = mkEnable;
        flakePath = mkOption {
          type = str;
          default = "/storage/Repos/crystal";
        };
      };
    };
  config =
    let
      inherit (lib) mkIf optionals;
      inherit (config._common) agenix cleanup nix;
    in
    {
      environment = {
        ### agenix setup
        systemPackages = mkIf agenix.setup [ inputs.agenix.packages.${pkgs.system}.default ];
        ### cleanup
        defaultPackages = mkIf cleanup [ ];
        ### nix setup
        etc."nix/inputs/nixpkgs".source = mkIf nix.config inputs.nixpkgs.outPath;
        sessionVariables.FLAKE = mkIf nix.config nix.flakePath;
      };
      ### agenix setup
      age.identityPaths = mkIf agenix.setup [ "/home/${config.users.users.main.name}/.ssh/id_ed25519" ];
      ### cleanup
      programs = mkIf cleanup {
        nano.enable = false;
        command-not-found.enable = false;
        bash.enableCompletion = false;
      };
      xdg.sounds.enable = mkIf cleanup false;
      documentation = mkIf cleanup {
        enable = false;
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
      };
      boot.enableContainers = mkIf cleanup false;
      ### nix setup
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
          use-xdg-base-directories = true;
          allowed-users = [ "@wheel" ];
          nix-path = [ "nixpkgs=flake:nixpkgs" ];
        };
        nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
        registry.nixpkgs.flake = inputs.nixpkgs;
        channel.enable = false;
        optimise.automatic = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };
      nixpkgs = {
        hostPlatform = "x86_64-linux";
        config.allowUnfree = true;
      };
      users.users.main.packages = optionals nix.nh [ pkgs.nh ];
    };
}
