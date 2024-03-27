{
  pkgs,
  lib,
  _lib,
  config,
  _colours,
  ...
}:
{
  options._desktop = _lib.mkEnable;
  config = lib.mkIf config._desktop {
    users.users.main.packages = builtins.attrValues {
      inherit (pkgs)
        wpaperd
        hypridle
        hyprlock
        xdg-utils
        wl-clipboard
        fuzzel
        ;
    };
    programs.hyprland.enable = true;
    _homeFile =
      let
        m1 = "DP-1";
        m2 = "HDMI-A-1";
        nls = a: b: lib.concatMapStringsSep "\n" a b;
        inherit (_colours) primary;
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
                path = /home/${config.users.users.main.name}/.cache/rwpspread/rwps_${n}.png
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
              "openrgb -p default"
            ]}
            ${nls (n: "env = ${n}") [
              "XCURSOR_SIZE,24"
              #"XCURSOR_THEME,phinger-cursors"
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
              col.inactive_border = 0xFF${primary.bg}
              col.active_border = 0xFF${primary.main}
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
        ".config/fuzzel/fuzzel.ini" = {
          source = (pkgs.formats.ini { }).generate "fuzzel.ini" {
            colors = {
              background = primary.bg + "FF";
              text = primary.fg + "FF";
              match = primary.main + "FF";
              border = primary.main + "FF";
            };
          };
        };
      };
    services = {
      greetd = {
        enable = true;
        settings.default_session = {
          command = "Hyprland";
          user = config.users.users.main.name;
        };
      };
      hardware.openrgb = {
        enable = true;
        motherboard = "amd";
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };
    security.rtkit.enable = true;
    fonts = {
      packages = builtins.attrValues {
        inherit (pkgs)
          noto-fonts
          noto-fonts-emoji
          noto-fonts-extra
          noto-fonts-cjk
          ;
      };
      fontconfig = {
        defaultFonts = {
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Sans" ];
          monospace = [ "Noto Mono" ];
        };
        subpixel.rgba = "rgb";
      };
    };
    boot = {
      plymouth.enable = true;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
      ];
    };
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      colors =
        let
          inherit (_colours) alpha accent primary;
        in
        [
          "000000" # match boot.
          alpha.red
          alpha.green
          alpha.yellow
          alpha.blue
          alpha.magenta
          alpha.cyan
          alpha.white
          accent.red
          accent.green
          accent.yellow
          accent.blue
          accent.magenta
          accent.cyan
          accent.white
          primary.fg
        ];
    };
  };
}
