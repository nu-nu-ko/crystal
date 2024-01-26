{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    snms.url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
    conduit = {
      url = "gitlab:famedly/conduit?ref=next";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mountain.url = "github:nu-nu-ko/mountain-nix";
    # awaiting pr's
    #qbit.url = "git+file:/storage/repos/nixpkgs?ref=nixos/qbittorrent-init";
    #jelly.url = "git+file:/storage/repos/nixpkgs?ref=nixos-jellyfin-dirs";
    jelly.url = "github:nu-nu-ko/nixpkgs?ref=nixos-jellyfin-dirs";
    qbit.url = "github:nu-nu-ko/nixpkgs?ref=nixos/qbittorrent-init";
  };
  outputs = inputs: let
    inherit (inputs.nixpkgs.lib) hasSuffix filesystem genAttrs nixosSystem;
  in {
    nixosConfigurations = let
      importAll = path:
        builtins.filter (hasSuffix ".nix")
        (map toString (filesystem.listFilesRecursive path));
    in
      genAttrs [
        "factory"
        "library"
      ] (name:
        nixosSystem {
          specialArgs = {inherit inputs;};
          modules =
            [./hosts/${name}.nix]
            ++ importAll ./libs
            ++ importAll ./mods;
        });
  };
}
