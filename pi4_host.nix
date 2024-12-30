{ config, pkgs, lib, ... }:

let
  hostname = "pi4test";
  user = "nixos";
  password = "hai";
  #nixosHardwareVersion = "7f1836531b126cfcf584e7d7d71bf8758bb58969";

  timeZone = "America/Los_Angeles";
  defaultLocale = "en_US.UTF-8";
in {
  imports = [
	#"${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/${nixosHardwareVersion}.tar.gz" }/raspberry-pi/4"
	];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-id/wwn-0x500a07512e906819-part3";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot/efi" = {
      device = "/dev/disk/by-id/wwn-0x500a07512e906819-part1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  }; #end of filesystem
  swapDevices = [
  	{ device = "/var/lib/swapfile"; size = 16*1024; }
  ]; #swapd devices list

  networking.hostName = hostname;
  networking.hostId = "12345678";
  environment.systemPackages = with pkgs; [
    curl
    wget
    vim
    git
  ];

  services.openssh.enable = true;

  #time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
    };
  };

  # Enable passwordless sudo.
  security.sudo.extraRules= [
    {  users = [ user ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  services.xserver = {
	enable = true;
	displayManager.lightdm.enable = true;
	desktopManager.xfce.enable = true;
	windowManager.qtile.enable = true;
	#windowManager.qtile.backend = "x11";
	windowManager.qtile.configFile = "/home/nixos/.config/qitle/config.py";
	windowManager.dwm.enable = true;
  }; #end of xserver  
  security.polkit.enable = true;
  services.displayManager.defaultSession = "xfce";
  services.picom = {
    enable = true;
    fade = true;
    inactiveOpacity = 0.9;
    shadow = true;
    fadeDelta = 4;
  }; #end of picom
  programs.xfconf.enable = true;
  nix.gc = {
  	automatic = true;
	dates = "23:15";
	options = "--delete-older-than 30d";
  }; #end of nix.gc
  #hardware.pulseaudio.enable = true;
  boot = {
    kernelPackages =  pkgs.linuxPackages;
    initrd.verbose = true;
    plymouth.enable = false;
    consoleLogLevel = 7;
    initrd.supportedFilesystems = [ "zfs" ];
    supportedFilesystems = [ "zfs" ];
    initrd.availableKernelModules = [ "pktgen" "xhci_pci" "usbhid" "uas" "usb_storage" ];
    loader.generic-extlinux-compatible.enable = false;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable =  true;
    kernelParams = [
      "efi=debug"
      "ignore_loglevel"
      "console=tty0"
    ]; #end of kernel parameters
  };#END OF BOOT BLOCK
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
