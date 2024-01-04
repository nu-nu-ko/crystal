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
        prompt = "'%F{red}書館%F{reset_color} %~ %% '";
      };
    };
    services = {
      fail2ban.enable = true;
      web = {
        enable = true;
        domain = "nuko.city";
        forgejo.enable = true;
        jellyfin.enable = false;
        qbit.enable = true;
        nextcloud.enable = true;
        vaultwarden.enable = true;
      };
      mailserver.enable = true;
    };
    programs = {
      htop.enable = true;
      neovim.enable = true;
    };
  };
  ### misc ###
  time.timeZone = "NZ";
  i18n.defaultLocale = "en_NZ.UTF-8";
  security.sudo.execWheelOnly = true;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  ### management user stuff ###
  age.secrets.user = {
    file = ../shhh/user.age;
    owner = config.users.users.main.name;
  };
  users = {
    mutableUsers = false;
    users = {
      main = {
        name = "nuko";
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["wheel"];
        hashedPasswordFile = config.age.secrets.user.path;
        packages = with pkgs; [
          wget
          git
          rsync
          eza
          yazi
          inputs.nh.packages.${pkgs.system}.default
        ];
        openssh.authorizedKeys.keys = [
          # factory / desktop
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ"
          # laptop
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrSQqI/X+I9fcQGOxgvTzZ2p/9SG4abc4xXkrAdRxBc"
          # phone
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZH8voUTYblnUaSThDyB+JrdFTVMVVxT4kA+EE+XrCG"
        ];
      };
    };
  };
  ### hardware ###
  networking = {
    hostName = "library";
    hostId = "9a350e7b";
    firewall.enable = true;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.enp6s0.ipv4.addresses = [
      {
        address = "192.168.0.3";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.0.1";
    nameservers = ["1.1.1.1" "1.1.0.0"];
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  powerManagement.cpuFreqGovernor = "performance";
  boot = {
    loader = {
      timeout = 0; # headless anyway
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true; # just incase
    };
    initrd.availableKernelModules = ["xhci_pci" "ahci" "sd_mod"];
    kernelModules = ["kvm-intel"];
    supportedFilesystems = ["zfs"];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part1";
      fsType = "vfat";
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
  swapDevices = [{device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part2";}];

  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
