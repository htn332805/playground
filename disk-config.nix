# Example to create a bios compatible gpt partition
{lib, ...}: {
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-id/wwn-0x500a07512e906819";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          }; # end of boot part
          ESP = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            }; #end of ESP Content
          }; #end of ESP part
          zfs = {
            name = "root";
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            }; #end of zfs content
          }; #end of zfs part
        }; #end of all the partitions
      }; #end of the disk content
    }; #end of disk config layout
    zpool = {
      rpool = {
        type = "zpool";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          atime = "off";
          recordsize = "1M";
          xattr = "sa";
          acltype = "posixacl";
          ashift = "12";
        };#end of rootFsOptions
        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";
        datasets = {
          zfs_fs = {
            type = "zfs_fs";
            mountpoint = "/zfs_fs";
            options."com.sun:auto-snapshot" = "true";
          };
        
      }; #end of datasets
    }; #end of rpool
  }; #end of zpool
}; #end of disko nix
}
