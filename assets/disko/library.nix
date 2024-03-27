{
  disko.devices =
    let
      # these are ID's tied to the disks hardware, are afaik the most reliable option.
      hdd1 = "/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WCC4N6KV50C2";
      hdd2 = "/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WMC4N0D6K3XX";
      hdd3 = "/dev/disk/by-id/ata-WDC_WD30EFZX-68AWUN0_WD-WX32DB0177FD";
      arc = "/dev/disk/by-id/ata-Samsung_SSD_840_Series_S14CNSAD126848W";
      ssd = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0";
    in
    {
      disk = {
        # root / system drive.
        ssd = {
          type = "disk";
          device = "${ssd}";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                device = "${ssd}-part1";
                type = "EF00";
                size = "1G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              swap = {
                device = "${ssd}-part2";
                size = "32G";
                content = {
                  type = "swap";
                  randomEncryption = true;
                };
              };
              root = {
                device = "${ssd}-part3";
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
        # main storage pool setup.
        # l2arc (cache)
        arc = {
          type = "disk";
          device = "${arc}";
          content = {
            type = "gpt";
            partitions.zfs.size = "100%";
          };
        };
        # main pool disks.
        hdd1 = {
          type = "disk";
          device = "${hdd1}";
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
        hdd2 = {
          type = "disk";
          device = "${hdd2}";
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
        hdd3 = {
          type = "disk";
          device = "${hdd3}";
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
            # lz4 may be better? but difference should be meaningless.
            compression = "zstd";
            # defaults to useless legacy compat.
            xattr = "sa";
            # no need to mount the pools, just the datasets is fine.
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
          mode = "raidz";
          rootFsOptions = {
            compression = "zstd";
            xattr = "sa";
            mountpoint = "none";
            # cache both metadata and sufficently small blocks.
            secondarycache = "all";
          };
          datasets = {
            "storage" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/storage";
              postCreateHook = "zpool add spool -f cache ${arc}-part1";
            };
            "state" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/var/lib";
            };
          };
        };
      };
    };
}
