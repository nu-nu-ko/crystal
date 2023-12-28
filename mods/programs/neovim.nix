{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.local.programs.neovim.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.programs.neovim.enable {
    users.users.main.packages = with pkgs; [
      (pkgs.callPackage ../../pkgs/neovim.nix {inherit inputs;})
      deadnix
      statix
      nil
      alejandra
    ];
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
}
