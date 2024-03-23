{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";
    # extras..
    agenix.url = "github:ryantm/agenix";
    snms.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    wsl.url = "github:nix-community/NixOS-WSL";
    # awaiting pr's # git+file/path/?ref=branch
    qbit.url = "github:nu-nu-ko/nixpkgs/?ref=init-nixos-qbittorrent";
    navi.url = "github:nu-nu-ko/nixpkgs/?ref=nixos-navidrome-cleanup";
    vault.url = "github:nu-nu-ko/nixpkgs/?ref=nixos-vaultwarden-hardening";
  };
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs.lib)
        genAttrs
        nixosSystem
        hasSuffix
        filesystem
        ;
      inherit (builtins)
        concatMap
        filter
        map
        toString
        ;
      genHosts =
        hosts:
        genAttrs hosts (
          name:
          nixosSystem {
            modules =
              concatMap (x: filter (hasSuffix ".nix") (map toString (filesystem.listFilesRecursive x))) [
                ./libs
                ./mods
              ]
              ++ [ ./hosts/${name}.nix ];
            specialArgs = {
              inherit inputs;
            };
          }
        );
    in
    {
      nixosConfigurations = genHosts [
        "factory"
        "library"
        "portal"
      ];
    };
}
