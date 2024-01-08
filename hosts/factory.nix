{
  pkgs,
  config,
  inputs,
  ...
}: {
  local = {
    misc = {
      nix = {
        config = true;
        flakePath = "/storage/crystal";
      };
      age.setup = true;
      clean.enable = true;
      root.disable = true;
      shell = {
        enable = true;
        prompt = "'%~ %% '";
      };
    };
    desktop = {
      enable = true;
      console = true;
      fonts = true;
      audio = true;
    };
    programs = {
      alacritty.enable = true;
      firefox.enable = true;
      htop.enable = true;
      neovim.enable = true;
      prism.enable = true;
    };
  };
  ### misc ###
  time.timeZone = "NZ";
  i18n.defaultLocale = "en_NZ.UTF-8";
  security = {
    sudo.execWheelOnly = true;
    tpm2.enable = true;
  };
  services.openssh.enable = true;
  ### user stuff ###
  age.secrets.user = {
    file = ../shhh/user.age;
    owner = config.users.users.main.name;
  };
  users = {
    mutableUsers = false; # more declaritve
    users.main = {
      name = "nuko";
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPasswordFile = config.age.secrets.user.path;
      packages = with pkgs; [
        # gui
        krita
        obs-studio
        imv
        mpv
        alacritty
        # games
        osu-lazer-bin
        protontricks
        r2modman
        # cli/tui
        git
        eza
        yazi
        ueberzugpp
        inputs.nh.packages.${pkgs.system}.default
      ];
    };
  };
  home.file = {
    "Documents".source = "/storage/Documents";
    "Downloads".source = "/storage/Downloads";
    "Pictures".source = "/storage/Pictures";
    "Crystal".source = "/storage/crystal";
    "Videos".source = "/storage/Videos";
  };
  # requires some system level setup.
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      # required for source1 games.
      extraLibraries = pkgs: [pkgs.pkgsi686Linux.gperftools];
    };
  };
  # removes 7sec boot delay lol
  systemd.services.systemd-udev-settle.enable = false;
  ### hardware ###
  networking = {
    hostName = "factory";
    hostId = "007f0200";
    firewall.enable = true;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.enp39s0.ipv4.addresses = [
      {
        address = "192.168.0.4";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.0.1";
    nameservers = ["1.1.1.1" "1.1.0.0"];
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = [
        pkgs.vaapiVdpau
        pkgs.libvdpau-va-gl
      ];
    };
    xone.enable = true;
  };
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  powerManagement.cpuFreqGovernor = "schedutil";
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    loader = {
      timeout = 0; # hold space to open the menu
      systemd-boot.enable = true;
    };
    plymouth.enable = true;
    initrd = {
      verbose = false;
      systemd.enable = true; # experimental.. seems cleaner
      kernelModules = ["amdgpu"];
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    };
    kernelModules = ["kvm-amd" "amd_pstate"];
    supportedFilesystems = ["zfs"];
    kernelParams = [
      "quiet"
      "splash"
      "video=DP-1:1920x1080@144"
      "video=HDMI-A-1:1920x1080@60"
      "initcall_blacklist=acpi_cpufreq_init"
      "amd_pstate=guided"
      "amd_pstate.shared_mem=1"
    ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part1";
      fsType = "vfat";
      options = ["rw" "noatime"];
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
  swapDevices = [{device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part2";}];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
