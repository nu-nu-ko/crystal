{ pkgs, lib, ... }:
{
  mods = {
    misc = {
      nix = {
        config = true;
        nh = true;
      };
      secrets = true;
      cleanDefaults = true;
      nztz = true;
      hostKey = true;
      wired = {
        enable = true;
        ip = "192.168.0.4";
        card = "enp39s0";
      };
    };
    user = {
      noRoot = true;
      main = {
        enable = true;
        shell.setup = true;
        packages = builtins.attrValues {
          inherit (pkgs)
            element-desktop
            teams-for-linux
            krita
            imv
            mpv
            ueberzugpp
            ;
          vesktop = pkgs.vesktop.override { withTTS = false; };
        };
        keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq" ];
      };
    };
    desktop = {
      hyprland = true;
      setup = {
        audio = true;
        rgb = true;
        plymouth = true;
      };
      theme = {
        fonts = true;
        gtkqt = true;
        console = true;
      };
      programs = {
        alacritty = true;
        firefox = true;
        prism = true;
        steam = true;
        fuzzel = true;
      };
    };
    programs = {
      git = true;
      ssh = true;
      neovim = true;
    };
  };
  home.file =
    lib.genAttrs
      [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Repos"
      ]
      (name: {
        source = "/storage/${name}";
      });
  ### misc
  security = {
    sudo.execWheelOnly = true;
    tpm2.enable = true;
  };
  ### networking
  networking = {
    hostName = "factory";
    hostId = "007f0200";
  };
  systemd = {
    # improves boot times
    services.systemd-udev-settle.enable = false;
    network.wait-online.enable = false;
  };
  services.openssh.hostKeys = [
    {
      comment = "factory host";
      path = "/etc/ssh/factory_ed25519_key";
      type = "ed25519";
    }
  ];
  # hardware
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelModules = [
      "kvm-amd"
      "amd_pstate"
    ];
    kernelParams = [ "amd_pstate=guided" ];
    loader = {
      timeout = 0; # hold space to open the menu.
      systemd-boot.enable = true;
    };
    initrd = {
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };
    supportedFilesystems = [ "zfs" ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part1";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
        "x-systemd.automount"
      ];
    };
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/storage" = {
      device = "spool/storage";
      fsType = "zfs";
    };
  };
  swapDevices = [ { device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part2"; } ];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
