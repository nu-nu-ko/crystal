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
        #package = pkgs.swayfx.overrideAttrs {passthru.providedSessions = ["sway"];};
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
          export WLR_RENDERER=vulkan
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
    home.file = let
      mod = "Mod4";
      d1 = "DP-1";
      d2 = "HDMI-A-1";

      grim = lib.getExe pkgs.grim;
      slurp = lib.getExe pkgs.slurp;
      jq = lib.getExe pkgs.jq;

      ccms = lib.concatMapStringsSep;

      lcp = config.local.colours.primary;
      lca = config.local.colours.alpha;
    in {
      ".config/sway/config".text = ''
        seat seat0 xcursor_theme phinger-cursors 24
        exec {
          systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
          autotiling-rs
          waybar
          swayidle -w before-sleep 'swaylock -f -c 000000'
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

        # visuals
        output ${d1} background wallpaper1 fill
        output ${d2} background wallpaper2 fill
        default_border pixel 3
        gaps inner 10
        #shadows enable
        client.focused #${lcp.main} #${lcp.main} #${lcp.main} #${lcp.main}
        client.unfocused #${lcp.bg} #${lcp.bg} #${lcp.bg} #${lcp.bg}
        client.focused_inactive #${lcp.bg} #${lcp.bg} #${lcp.bg} #${lcp.bg}

        xwayland enable

        bindsym ${mod}+Return exec alacritty
        bindsym ${mod}+Shift+q kill
        bindsym ${mod}+d exec wofi --show drun -a -W 15% -H 35%
        bindsym ${mod}+Shift+s exec ${grim} -g "$(${slurp} -d)" - | wl-copy -t image/png
        bindsym ${mod}+Shift+d exec ${grim} -g "$(swaymsg -t get_tree | ${jq} -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${slurp} -d)" - | wl-copy -t image/png
        bindsym ${mod}+Shift+e exec swaynag -t warning -m 'confirm quit sway' -B 'confirm' 'swaymsg exit'
        bindsym ${mod}+l exec swaylock -f -c 000000

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
      '';
      ".config/waybar/config".text = ''
        [
          {
            "layer": "bottom",
            "position": "left",
            "output": "${d1}",
            "spacing": 10,
            "margin-top": 10,
            "margin-bottom": 10,
            "margin-left": 10,
            "modules-left": [ "sway/workspaces" ],
            "modules-right": [ "pulseaudio", "clock"],

            "sway/workspaces": {
                "disable-scroll": true,
                "all-outputs": false,
                "format": "{name}",
            },
            "pulseaudio": {
                "scroll-step": 5,
                "format": "{icon}\n{format_source}",
                "format-muted": "󰝟\n{format_source}",
                "format-source": "",
                "format-source-muted": "",
                "format-icons": {
                    "default": ["", ""]
                },
                "tooltip": true,
                "tooltip-format": "{volume}%"
            },
            "clock": {
                "format": "{:%H\n%M}",
                "tooltip-format": "{:%Y-%m-%d}"
            }
            },
          {
            "layer": "bottom",
            "position": "right",
            "output": "${d2}",
            "spacing": 10,
            "margin-top": 10,
            "margin-bottom": 10,
            "margin-right": 10,
            "modules-left": [ "sway/workspaces" ],
            "modules-right": [ "tray", "network", "pulseaudio", "clock"],

            "sway/workspaces": {
                "disable-scroll": true,
                "all-outputs": false,
                "format": "{name}",
            },
            "pulseaudio": {
                "scroll-step": 5,
                "format": "{icon}\n{format_source}",
                "format-muted": "󰝟\n{format_source}",
                "format-source": "",
                "format-source-muted": "",
                "format-icons": {
                    "default": ["", ""]
                },
                "tooltip": true,
                "tooltip-format": "{volume}%"
            },
            "network": {
                "format-ethernet": "󰈀",
                "format-disconnected": "",
                "tooltip-format": "{ipaddr}/{ifname}"
            },
            "clock": {
                "format": "{:%H\n%M}",
                "tooltip-format": "{:%Y-%m-%d}"
            },
            "tray": {
                "icon-size": 16,
                "spacing": 10
            }
          }
        ]
      '';
      ".config/waybar/style.css".text = ''
        * {
            font-family: 'Liga SFMono Nerd Font';
            font-size: 14px;
        }
        window#waybar {
            background-color: transparent;
            transition-property: background-color;
            transition-duration: .5s;
        }
        window#waybar.empty #window {
            background-color: transparent;
        }

        #workspaces {
            padding: 0px;
            border-radius: 0px;
            border:2px solid #${lca.black};
            background-color: #${lcp.bg};
            color: #${lcp.fg};
        }
        #worksapces button {
            padding: 2px;
        }
        #workspaces button:hover {
            border-radius: 0px;
        }
        #workspaces button.focused {
            color: #${lcp.main};
        }
        #workspaces button.urgent {
            color: #${lcp.main};
        }

        #network,
        #pulseaudio,
        #tray,
        #clock {
            border-radius: 0px;
            border:2px solid #${lca.black};
            background-color: #${lcp.bg};
            color: #${lcp.fg};
            padding: 2px;
        }

        tooltip label {
            background-color: #${lcp.bg};
            color: #${lcp.fg};
            border-radius: 0px;
            border:2px solid #${lca.black};
        }
      '';
      ".config/wofi/style.css".text = ''
        #window {
            border: 3px solid #${lcp.main};
        }
        #input {
            marfin: 15px;
        }
        #inner-box {
            margin: 0px 15px 15px 15px;
        }
        #entry {
            margin: 5px;
        }
        #entry:selected {
            color: #${lcp.main};
        }
      '';
    };
  };
}
