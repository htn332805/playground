# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
#nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=/mnt/etc/nixos/configuration.nix
#sudo nixos-install --root /mnt


{ config, lib, pkgs, ... }:
let
		h_a_i= "/mnt";
in
{
  imports =
    [ # Include the results of the hardware scan.
	./home-manager-release-24.05/nixos
	./hardware-configuration.nix
	./impermanence/nixos.nix
	./modules/basic_webserver.nix
	./modules/blog.nix
	./modules/xfce4.nix
	./modules/gns3.nix
	./modules/xrdp.nix
	./modules/system_packages.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

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
    zfs = {
  	forceImportRoot = true;
  	extraPools = [ "zroot" ];
	}; #end of zfs
  };#END OF BOOT BLOCK
  
  systemd.services.zfs-import-pools = {
  	description = "Import ZFS pools";
  	wantedBy = [ "zfs.target" ];
  	before = [ "zfs.target" ];
  	serviceConfig = {
    		Type = "oneshot";
    		RemainAfterExit = true;
    		ExecStart = "${config.boot.zfs.package}/bin/zpool import -a -f";
  	};
  }; #end of sytemd

  networking = {
	hostName = lib.mkForce "nixpi";
  	networkmanager.enable = true;
  	useDHCP = false;
	hostId = "12345678";
  	interfaces.eth0.useDHCP = true;
  	interfaces.wlan0.useDHCP = true;
  }; #END OF NETWORKING BLOCK

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.nixos = {
     isNormalUser = true;
     initialPassword = "hai";
     extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       git wget curl firefox tree chromium nb freeplane tmux screen htop btop nload 
     ]; #end of user package
   }; #ENDO OF USERS CONFIG

  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
   
  nix.gc = {
  	automatic = true;
	dates = "23:15";
	options = "--delete-older-than 30d";
  }; #end of nix.gc

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # might not be needed
  programs.fuse.userAllowOther = true;
  # Home Manager config goes in here
  home-manager.users.nixos = {
    home.homeDirectory = "/home/nixos";
    #imports = [ "/mnt/etc/nixos/impermanence/home-manager.nix" ];
    imports = [ "/etc/nixos/impermanence/home-manager.nix" ];
    #imports = [ "${impermanence}/home-manager.nix" ];
    programs = {
      home-manager.enable = true;
      git = {   # can use home-manager normally as well as with persistence
        enable = true;
        userName  = "htn332805";
        userEmail = "htn33280@hotmail.com";
      }; #end of git
    }; #end of program within home manager
    home.persistence."/nix/dotfiles" = {
      removePrefixDirectory = true;   # for GNU Stow styled dotfile folders
      allowOther = true;
      directories = [
        "nixos/.config"   
        # fuse mounted from /nix/dotfiles/Firefox/.mozilla to /home/$USERNAME/.mozilla
        "Firefox/.mozilla"
      ]; #end of directories list
      files = [
        "nixos/.config/home_persistent.file"
      ]; #end of files list
    }; #end of home.persistent
    home.persistence."/nix/dotfiles/Plasma" = {
      removePrefixDirectory = false;
      allowOther = true;
      directories = [
        ".config/gtk-3.0"   # fuse mounted from /nix/dotfiles/Plasma/.config/gtk-3.0
        ".config/gtk-4.0"     # to /home/$USERNAME/.config/gtk-3.0
      ]; #end directories
      files = [
        ".local/share/user-places.xbel.tbcache"
      ]; #end files
    }; #end home.persistent
    home.stateVersion = "24.05";
  }; #END HOME-MANGER.users
  
  system.copySystemConfiguration = true;
  system.stateVersion = "24.05"; # Did you read the comment?

} # END OF CONFIG FILE

