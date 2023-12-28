{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.local.desktop.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.desktop.enable {
    programs = {
      # if tty1 any no existing session, start sway imediately.
      zsh.loginShellInit = ''
        if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec sway
        fi
      '';
      sway = {
        enable = true;
        # swayfx is a fork with some visual mods.
        package = pkgs.swayfx.overrideAttrs {passthru.providedSessions = ["sway"];};
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          # theme stuff.
          phinger-cursors
          inputs.mountain.packages.${pkgs.system}.gtk
          flat-remix-icon-theme

          vulkan-validation-layers # vulkan req, currently waiting on a fix from upstream.
          xdg-utils # defines what opens where.
          autotiling-rs # tile rules.
          swaylock
          swayidle
          wl-clipboard
          wofi
          waybar
        ];
        # nixos uses logind by default not seatd, java apps need the bottom flag.
        extraSessionCommands = ''
          export LIBSEAT_BACKEND=logind
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
      # gtk4 / opts sets.
      dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              gtk-theme = "phocus-mountain";
              icon-theme = "Flat-Remix-Purple-Dark";
              cursor-theme = "phinger-cursors";
              font-name = "SF Pro Text 12";
              monospace-font-name = "Liga SFMono Nerd Font";
              document-font-name = "SF Pro Text 12";
            };
          }
        ];
      };
    };
    environment.etc = {
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name=phinger-cursors
        gtk-font-name=SF Pro Text 12
        gtk-icon-theme-name=Flat-Remix-Purple-Dark
        gtk-theme-name=phocus-mountain
      '';
      # this is for qt compat
      "xdg/gtk-2.0/gtkrc".text = ''
        gtk-theme-name = "phocus-mountain"
      '';
    };
    qt = {
      enable = true;
      style = "gtk2";
      platformTheme = "gtk2";
    };
    home.file.".config/sway/config".text = let
      mod = "Mod4";
      d1 = "DP-1";
      d2 = "HDMI-A-1";

      grim = lib.getExe pkgs.grim;
      slurp = lib.getExe pkgs.slurp;
      jq = lib.getExe pkgs.jq;
      ccms = lib.concatMapStringsSep;
      lcp = config.local.colours.primary;
    in ''
      seat seat0 xcursor_theme phinger-cursors 24
      exec {
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
        autotiling-rs
        waybar
      }

      output ${d1} {
          mode 1920x1080@144Hz
          position 0,0
          adaptive_sync on
      }
      output ${d2} {
          mode 1920x1080@60Hz
          position 1920,0
      }
      input "5426:132:Razer_Razer_DeathAdder_V2" {
          accel_profile flat
      }

      bindsym ${mod}+Return exec alacritty
      bindsym ${mod}+Shift+q kill
      bindsym ${mod}+d exec wofi --show drun
      bindsym ${mod}+Shift+s exec ${grim} -g "$(${slurp} -d)" - | wl-copy -t image/png
      bindsym ${mod}+Shift+d exec ${grim} -g "$(swaymsg -t get_tree | ${jq} -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${slurp} -d)" - | wl-copy -t image/png
      bindsym ${mod}+Shift+e exec swaynag -t warning -m 'confirm quit sway' -B 'confirm' 'swaymsg exit'
      bindsym ${mod}+l exec swaylock

      floating_modifier ${mod} normal
      bindsym ${mod}+Shift+a floating toggle
      bindsym ${mod}+Shift+z fullscreen toggle

      # move client focus
      bindsym ${mod}+Left focus left
      bindsym ${mod}+Down focus down
      bindsym ${mod}+Up focus up
      bindsym ${mod}+Right focus right
      # move focused client
      bindsym ${mod}+Shift+Left move left
      bindsym ${mod}+Shift+Down move down
      bindsym ${mod}+Shift+Up move up
      bindsym ${mod}+Shift+Right move right

      # bind workspaces to specific monitors
      ${ccms "\n" (n: "workspace ${n} output ${d1}") ["1" "2" "3" "4"]}
      ${ccms "\n" (n: "workspace ${n} output ${d2}") ["5" "6" "7" "8"]}
      # move focus / +Shift move focused client to workspace
      ${ccms "\n" (n: "bindsym ${mod}+${n} workspace number ${n}") ["1" "2" "3" "4" "5" "6" "7" "8"]}
      ${ccms "\n" (n: "bindsym ${mod}+Shift+${n} move container to workspace number ${n}") ["1" "2" "3" "4" "5" "6" "7" "8"]}

      # visuals
      output * background wallpaper fill
      default_border pixel 3
      gaps inner 10
      xwayland enable

      client.focused #${lcp.main} #${lcp.main} #${lcp.main} #${lcp.main}
      client.unfocused #${lcp.bg} #${lcp.bg} #${lcp.bg} #${lcp.bg}
      client.focused_inactive #${lcp.bg} #${lcp.bg} #${lcp.bg} #${lcp.bg}

      shadows enable
    '';
  };
}
