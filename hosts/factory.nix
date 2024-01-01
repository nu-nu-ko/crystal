{
  pkgs,
  config,
  inputs,
  ...
}: {
  local = {
    misc = {
      nix.config = true;
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
  # requires system-level setup
  programs.steam.enable = true;
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
  powerManagement.cpuFreqGovernor = "schedutil";
  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
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
    supportedFilesystems = ["bcachefs"];
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
  fileSystems = let
    defaults = ["rw" "noatime" "compression=lz4" "background_compression=lz4" "discard"];
  in {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["rw" "noatime"];
    };
    "/" = {
      device = "/dev/disk/by-label/factory";
      fsType = "bcachefs";
      options = defaults;
    };
    "/storage" = {
      device = "/dev/disk/by-label/storage";
      fsType = "bcachefs";
      options = defaults;
    };
    "/storage/games" = {
      device = "/dev/disk/by-label/games";
      fsType = "bcachefs";
      options = defaults;
    };
  };
  #swapDevices = [{device = "/swap";}];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
