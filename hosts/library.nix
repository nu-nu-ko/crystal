{ lib, ... }:
{
  mods = {
    misc = {
      nix = {
        config = true;
        flakePath = "/storage/repos/crystal";
        nh = true;
      };
      secrets = true;
      cleanDefaults = true;
      nztz = true;
      hostKey = true;
      wired = {
        enable = true;
        ip = "192.168.0.3";
        card = "enp6s0";
      };
    };
    user = {
      noRoot = true;
      main = {
        enable = true;
        shell = {
          setup = true;
          prompt = "'%F{magenta}圖書館%F{reset_color} %~ %# '";
        };
        keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ" ];
      };
    };
    programs = {
      neovim = true;
      git = true;
      ssh = true;
    };
    services = {
      fail2ban = true;
      postgresql = true;
      openssh = true;
      prometheus = true;
      mail = true;
      synapse = true;
      web = {
        nginx.enable = true;
        komga.enable = true;
        navidrome.enable = true;
        forgejo.enable = true;
        vaultwarden.enable = true;
        nextcloud.enable = true;
        qbittorrent.enable = true;
        grafana.enable = true;
      };
    };
  };
  ### misc
  security.sudo.execWheelOnly = true;
  users.groups.media = { };
  systemd = {
    # shouldn't be able to get to these anyway
    services = {
      "getty@tty1".enable = false;
      "autovt@".enable = false;
      "serial-getty@ttyS0".enable = lib.mkDefault false;
      "serial-getty@hvc0".enable = false;
    };
    enableEmergencyMode = false;
  };
  ### networking
  networking = {
    domain = "shimeji.cafe";
    hostName = "library";
    hostId = "9a350e7b";
  };
  ### hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  powerManagement.cpuFreqGovernor = "powersave";
  boot = {
    kernelParams = [
      "panic=1"
      "boot.panic_on_fail"
    ];
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part1";
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
    "/var/lib" = {
      device = "spool/state";
      fsType = "zfs";
    };
  };
  swapDevices = [ { device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part2"; } ];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
