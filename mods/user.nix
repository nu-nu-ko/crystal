{
  pkgs,
  lib,
  nuke,
  config,
  ...
}:
{
  options.mods.user =
    let
      inherit (nuke) mkEnable;
      inherit (lib) mkOption;
      inherit (lib.types)
        str
        listOf
        package
        lines
        ;
    in
    {
      noRoot = mkEnable;
      main = {
        enable = mkEnable;
        name = mkOption {
          type = str;
          default = "nuko";
        };
        packages = mkOption {
          type = listOf package;
          default = [ ];
        };
        keys = mkOption {
          type = listOf str;
          default = [ ];
        };
        shell = {
          setup = mkEnable;
          prompt = mkOption {
            type = lines;
            default = "`%~ %# '";
          };
        };
      };
    };
  config =
    let
      inherit (lib)
        mkIf
        mkForce
        mkDefault
        getExe
        ;
      inherit (config.mods.user) main noRoot;
      inherit (main) shell;
    in
    {
      age.secrets.user = mkIf main.enable {
        file = ../shhh/user.age;
        owner = main.name;
      };
      users = {
        mutableUsers = mkDefault false;
        users = {
          ### disableRoot
          root = mkIf noRoot {
            hashedPassword = mkDefault "!";
            shell = mkForce pkgs.shadow;
            home = mkDefault "/home/root"; # for sudo.
          };
          ### configure main user
          main = mkIf main.enable {
            uid = 1000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPasswordFile = config.age.secrets.user.path;
            inherit (main) name;
            packages = builtins.attrValues { inherit (pkgs) wget yazi eza; } ++ main.packages;
            openssh.authorizedKeys.keys = main.keys;
            ### shell setup
            shell = mkIf shell.setup pkgs.zsh;
          };
        };
      };
      ### shell setup
      environment = mkIf shell.setup {
        shells = [ pkgs.zsh ];
        binsh = getExe pkgs.dash;
        variables = {
          XDG_DATA_HOME = ''"$HOME"/.local/share'';
          XDG_CONFIG_HOME = ''"$HOME"/.config'';
          XDG_STATE_HOME = ''"$HOME"/.local/state'';
          XDG_CACHE_HOME = ''"$HOME"/.cache'';
        };
      };
      programs.zsh = mkIf shell.setup {
        enable = shell.setup;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        histSize = 10000;
        histFile = "$HOME/.cache/zsh_history";
        shellInit = ''
          zsh-newuser-install() { :; }
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey '^H' backward-kill-word
          bindkey '5~' kill-word
          (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
          ZSH_HIGHLIGHT_STYLES[path]=none
          ZSH_HIGHLIGHT_STYLES[path_prefix]=none
          nr() {
            nix run nixpkgs#$1 -- ''${@:2}
          }
          ns() {
            nix shell nixpkgs#''${^@}
          }
        '';
        shellAliases = {
          ls = "eza";
          lg = "eza -lag";
          nf = "nix flake";
          no = "nh os";
          grep = "grep --color=auto";
          library = "ssh 192.168.0.3";
          pass = "wl-copy < /home/${config.users.users.main.name}/Documents/vault";
        };
        promptInit = "PROMPT=${shell.prompt}";
      };
    };
}
