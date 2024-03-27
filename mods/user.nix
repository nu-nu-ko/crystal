{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._user =
    let
      inherit (_lib) mkEnable;
      inherit (lib) mkOption types;
      inherit (types)
        str
        listOf
        package
        lines
        ;
    in
    {
      disableRoot = mkEnable;
      mainUser = {
        enable = mkEnable;
        packages = mkOption {
          type = listOf package;
          default = [ ];
        };
        loginKeys = mkOption {
          type = listOf str;
          default = [ ];
        };
        shell = {
          setup = mkEnable;
          prompt = mkOption {
            type = lines;
            default = "'%~ %# '";
          };
        };
      };
    };
  config =
    let
      inherit (lib) mkIf mkDefault mkForce;
      inherit (config._user) mainUser disableRoot;
    in
    {
      age.secrets.user = mkIf mainUser.enable {
        file = ../assets/age/user.age;
        owner = config.users.users.main.name;
      };
      users = {
        mutableUsers = mkIf mainUser.enable true;
        users = {
          main = mkIf mainUser.enable {
            name = "nuko";
            uid = 1000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPasswordFile = config.age.secrets.user.path;
            openssh.authorizedKeys.keys = mainUser.loginKeys;
            shell = mkIf mainUser.shell.setup pkgs.zsh;
            packages = builtins.attrValues { inherit (pkgs) wget yazi eza; } ++ mainUser.packages;
          };
          root = mkIf disableRoot {
            hashedPassword = mkDefault "!"; # cannot eval.
            home = mkDefault "/home/root"; # for sudo use.
            shell = mkForce pkgs.shadow;
          };
        };
      };
      environment = mkIf mainUser.shell.setup {
        shells = [ pkgs.zsh ];
        binsh = lib.getExe pkgs.dash;
        variables = {
          XDG_DATA_HOME = ''"$HOME"/.local/share'';
          XDG_CONFIG_HOME = ''"$HOME"/.config'';
          XDG_STATE_HOME = ''"$HOME"/.local/state'';
          XDG_CACHE_HOME = ''"$HOME"/.cache'';
        };
      };
      programs.zsh =
        let
          inherit (mainUser.shell) setup prompt;
        in
        mkIf setup {
          enable = true;
          promptInit = "PROMPT=${prompt}";
          shellAliases = {
            ls = "eza";
            lg = "eza -lag";
            nf = "nix flake";
            library = "ssh 192.168.0.3";
            pass = "wl-copy < /home/${config.users.users.main.name}/Documents/vault";
          };
          shellInit = ''
            nr() {
              nix run nixpkgs#$1 -- ''${@:2}
            }
            ns() {
              nix shell nixpkgs#''${^@}
            }
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
            bindkey '^H' backward-kill-word
            bindkey '5~' kill-word
            (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[path]=none
            ZSH_HIGHLIGHT_STYLES[path_prefix]=none
            zsh-newuser-install() { :; }
          '';
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
          histFile = "$HOME/.cache/zsh_history";
          histSize = 10000;
        };
    };
}
