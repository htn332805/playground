{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x500a07512e906819";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "256M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              }; #end of content
            }; #end of ESP
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              }; #end of content
            }; #end of zfs part
          }; #end of partitions layout
        }; #end of main content
      };#end of main block
    }; #end of disk block
    zpool = {
      rpool = {
        type = "zpool";
        mode = "single";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          canmount = "off";
          xattr = "sa";
          relatime = "on";
          normalization = "formD";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/pass-zpool-rpool";
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        postCreateHook = ''
          zfs set keylocation="prompt" rpool
        '';
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          }; #end of "local" block
          safe = {
            type = "zfs_fs";
            options.mountpoint = "none";
          }; #end of "safe" block
          "local/reserved" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "1GiB";
            };
          }; #end of "local/reserved" block
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot rpool/local/root@blank
            '';
          }; #end of "local/root" block
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          }; #end of "local/nix" block
          "local/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          }; #end of "local/log" block
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          }; #end of "safe/home" block
          "safe/persistent" = {
            type = "zfs_fs";
            mountpoint = "/persistent";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };#end of "safe/persistent" block
        }; #end of dataset block
      }; #end of rpool block
    };#end of zpool block
  }; #end of disko.device block
}
