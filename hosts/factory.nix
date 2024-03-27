{ pkgs, lib, ... }:
{
  _common = {
    nix = {
      config = true;
      nh = true;
    };
    agenix.setup = true;
    cleanup = true;
  };
  _system = {
    timeZone.NZ = true;
    setHostKey = true;
    wired = {
      enable = true;
      ip = "192.168.0.4";
      name = "enp39s0";
    };
  };
  _user = {
    disableRoot = true;
    mainUser = {
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
      loginKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq" ];
    };
  };
  _programs = {
    alacritty = true;
    firefox = true;
    steam = true;
    prismlauncher = true;
    git = true;
    ssh = true;
    neovim = true;
    htop = true;
  };
  _desktop = true;
  #_homeFile =
  #  lib.genAttrs
  #    [
  #      "Documents"
  #      "Downloads"
  #      "Pictures"
  #      "Videos"
  #      "Repos"
  #    ]
  #    (name: {
  #      source = "/storage/${name}";
  #    });
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
      "amdgpu"
    ];
    kernelParams = [ "amd_pstate=guided" ];
    loader = {
      timeout = 0; # hold space to open the menu.
      systemd-boot.enable = true;
    };
    initrd.systemd.enable = true;
    supportedFilesystems = [ "zfs" ];
  };
  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/storage" = {
      device = "spool/storage";
      fsType = "zfs";
    };
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
  };
  swapDevices = [ { device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part2"; } ];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
