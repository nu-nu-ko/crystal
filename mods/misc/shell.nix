{
  lib,
  config,
  pkgs,
  ...
}: {
  options.local.misc.shell = {
    enable = lib.mkEnableOption "";
    prompt = lib.mkOption {type = lib.types.lines;};
  };
  config = lib.mkIf config.local.misc.shell.enable {
    users.users.main.shell = lib.mkForce pkgs.zsh;
    environment = {
      shells = [pkgs.zsh];
      binsh = lib.getExe pkgs.dash; #speed!
      variables = {
        # keep ~ clean.
        XDG_DATA_HOME = "\"$HOME\"/.local/share";
        XDG_CONFIG_HOME = "\"$HOME\"/.config";
        XDG_STATE_HOME = "\"$HOME\"/.local/state";
        XDG_CACHE_HOME = "\"$HOME\"/.cache";
        XCOMPOSECACHE = "\"$XDG_CACHE_HOME\"/X11/xcompose";
        ERRFILE = "\"$XDG_CACHE_HOME\"/X11/xsession-errors";
      };
      sessionVariables.FLAKE = "/storage/crystal";
    };
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableGlobalCompInit = false;
      histSize = 10000;
      histFile = "$HOME/.cache/zsh_history";
      shellInit = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        # ctrl backwards / delete
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word
        # disable weird underline
        (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[path]=none
        ZSH_HIGHLIGHT_STYLES[path_prefix]=none
        zsh-newuser-install() { :; }
        runix() {
            nix run nixpkgs#$1 -- "''${@:2}"
        }
      '';
      shellAliases = {
        ls = "eza";
        ssh-library = "ssh 192.168.0.7 -p 56789";
      };
      promptInit = "PROMPT=${config.local.misc.shell.prompt}";
    };
  };
}
