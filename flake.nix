{
  inputs = {
    jf.url = "github:nu-nu-ko/nixpkgs?ref=nixos-jellyfin-dirs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    snms = {
      url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mountain = {
      url = "github:nu-nu-ko/mountain-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    jf,
    nixpkgs,
    agenix,
    snms,
    ...
  } @ inputs: let
    importAll = path:
      builtins.filter (nixpkgs.lib.hasSuffix ".nix")
      (map toString (nixpkgs.lib.filesystem.listFilesRecursive path));
  in {
    nixosConfigurations = {
      factory = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [
            ./hosts/factory.nix
            agenix.nixosModules.default
          ]
          ++ importAll ./libs
          ++ importAll ./mods;
      };
      library = jf.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [
            ./hosts/library.nix
            agenix.nixosModules.default
            snms.nixosModules.default
          ]
          ++ importAll ./libs
          ++ importAll ./mods;
      };
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
