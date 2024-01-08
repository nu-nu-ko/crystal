{
  disko.devices = let
    nvme1 = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A";
    nvme2 = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D";
    sata1 = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S3YBNB0N912941N";
    sata2 = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S6P5NX0T317019K";
  in {
    disk = {
      # root / system drive.
      nvme1 = {
        type = "disk";
        device = "${nvme1}";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              device = "${nvme1}-part1";
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              device = "${nvme1}-part2";
              size = "64G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            root = {
              device = "${nvme1}-part3";
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
      sata1 = {
        type = "disk";
        device = "${sata1}";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "spool";
            };
          };
        };
      };
      sata2 = {
        type = "disk";
        device = "${sata2}";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "spool";
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          mountpoint = "none";
        };
        datasets."root" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/";
        };
      };
      spool = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          mountpoint = "none";
        };
        datasets."root" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/storage";
        };
      };
    };
  };
}
