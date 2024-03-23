{
  pkgs,
  lib,
  nuke,
  config,
  colours,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (nuke) mkEnable;
in
{
  options.mods.desktop.hyprland = mkEnable;
  config = mkIf config.mods.desktop.hyprland {
    programs.hyprland.enable = config.mods.desktop.hyprland;
    users.users.main.packages = builtins.attrValues {
      inherit (pkgs)
        wpaperd
        hypridle
        xdg-utils
        wl-clipboard
        hyprlock
        fuzzel
        ;
    };
    home.file =
      let
        m1 = "DP-1";
        m2 = "HDMI-A-1";
        inherit (colours.primary) bg main;
        nls = a: b: lib.concatMapStringsSep "\n" a b;
      in
      {
        ".config/hypr/hypridle.conf".text = ''
          general {
            lock_cmd = hyprlock
            before_sleep_cmd = hyprlock
          }
          listener {
            timeout = 300
            on-timeout = hyprlock
          }
          listener {
            timeout = 600
            on-timeout = systemctl suspend
          }
        '';
        ".config/hypr/hyprlock.conf".text = ''
          general {
            disable_loading_bar = true
            hide_cursor = false
            no_fade_in = true
          }
          ${nls
            (n: ''
              background {
                monitor = ${n}
                path = /home/nuko/.cache/rwpspread/rwps_${n}.png
                brightness = 0.8
                blur_size = 7
                blur_passes = 1
              }
            '')
            [
              m1
              m2
            ]
          }
          input-field {
            monitor = ${m1}
            size = 200, 50
            outline_thickness = 3
            position = 0, -20
            halign = center
            valign = center
            fade_on_empty = false
          }
        '';
        ".config/hypr/hyprland.conf".text =
          let
            inherit (lib) range getExe;
            inherit (pkgs) grim slurp;
          in
          ''
            ${nls (n: "exec-once = ${n}") [
              "hyprlock"
              "hypridle"
              "wpaperd"
            ]}
            ${nls (n: "env = ${n}") [
              "XCURSOR_SIZE,24"
              "XCURSOR_THEME,phinger-cursors"
              "QT_QPA_PLATFORMTHEME,qt5ct"
              "_JAVA_AWT_WM_NONREPARENTING,1"
            ]}
            monitor=${m1},highrr,auto,auto
            monitor=${m2},preferred,auto,auto
            input {
              accel_profile = flat
            }
            device {
              name = wacom-intuos-s-2-pen
              output = ${m1}
            }
            general {
              border_size = 2
              gaps_out = 6
              gaps_in = 3
              col.inactive_border = 0xFF${bg}
              col.active_border = 0xFF${main}
            }
            decoration {
              rounding = 3
              drop_shadow = true
              blur {
                enabled = false
              }
            }
            animations {
              enabled = true
              animation=global,1,1,default
              first_launch_animation = false
            }
            misc {
              disable_hyprland_logo = true
              disable_splash_rendering = true
              force_default_wallpaper = 0
              animate_manual_resizes = true
              animate_mouse_windowdragging = true
              vrr = 1
            }
            dwindle {
              preserve_split = true
              force_split = 2
            }
            ${nls (n: "workspace=${n},monitor:${m1}") (map toString (range 1 4))}
            ${nls (n: "workspace=${n},monitor:${m2}") (map toString (range 5 8))}
            ${nls (n: "bind=${n}") [
              "SUPER, Return, exec, alacritty"
              "SUPER, D, exec, fuzzel"
              "SUPER, L, exec, hyprlock"
              ''SUPER_SHIFT, S, exec, ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png''
              "SUPER_SHIFT, Q, killactive,"
              "SUPER_SHIFT, Z, fullscreen,"
              "SUPER, Z, togglefloating,"
              "SUPER, left, movefocus, l"
              "SUPER, right, movefocus, r"
              "SUPER, up, movefocus, u"
              "SUPER, down, movefocus, d"
            ]}
            ${nls (n: "bind=SUPER,${n},workspace,${n}") (map toString (range 1 8))} 
            ${nls (n: "bind=SUPER_SHIFT,${n},movetoworkspacesilent,${n}") (map toString (range 1 8))}
            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow
          '';
      };
  };
}
