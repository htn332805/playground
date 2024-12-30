#git clone https://github.com/htn332805/playground.git && cd playground && nixos-rebuild -v --flake .#pi4test switch
{ config, pkgs, lib, ... }:

let
  hostname = "pi4test";
  user = "nixos";
  password = "hai";

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
    "/boot" = {
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
    git curl wget vim neovim nb tmux screen htop nload tree fio sysstat
    python3
    python3Packages.pip
  ];

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
      # FIXME: change your shell here if you don't want fish
      shell = pkgs.fish;
      extraGroups = [ "wheel" "networking" "docker" ];
      # FIXME: add your own hashed password
      # hashedPassword = "";
      # FIXME: add your own ssh public key
      # openssh.authorizedKeys.keys = [
      #   "ssh-rsa ..."
      # ];
      packages = with pkgs; [
				(python3.withPackages (ps: with ps; [
    	  			# Add your desired Python packages here, for example:
					numpy pandas matplotlib scipy dash flask jupyterlab reader
  			])) # end of python3 packages
			]; #end of packages

    }; #end of users.users.user
  };
  #setup virtual environment for user
  system.activationScripts.pythonSetup = ''
  mkdir -p /home/${user}/.venv
  ${pkgs.python3}/bin/python3 -m venv /home/${user}/.venv
  chown -R ${user}:users /home/${user}/.venv
'';
  # add the virtual environment to PATH
  environment.shellInit = ''
  	export PATH="/home/${user}/.venv/bin:$PATH"
	'';

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
  #hardware.raspberry-pi."4".fkms-3d.enable = true;
  services.xserver = {
	enable = true;
	displayManager.lightdm.enable = true;
	desktopManager.xfce.enable = true;
	windowManager.qtile.enable = true;
	windowManager.qtile.configFile = "/home/nixos/.config/qitle/config.py";
	windowManager.dwm.enable = true;
  }; #end of xserver
  services.xserver.displayManager.lightdm.extraConfig = ''
	greeter-show-manual-login=true
  	allow-guest=false
  '';
  security.pam.services.lightdm.enableGnomeKeyring = true;
  security.pam.services.lightdm-greeter.enableGnomeKeyring = true;
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
  users.users.root.initialPassword = password;
  # FIXME: change your shell here if you don't want fish
  programs.fish.enable = true;
  environment.pathsToLink = ["/share/fish"];
  environment.shells = [pkgs.fish];
  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;
  # FIXME: uncomment the next line to enable SSH
  services.openssh.enable = true;

  home-manager.users.${user} = {
    imports = [
      ./home.nix
    ];
  };
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
  nix = {
    settings = {
      trusted-users = [user];
      # FIXME: use your access tokens from secrets.json here to be able to clone private repos on GitHub and GitLab
      # access-tokens = [
      #   "github.com=${secrets.github_token}"
      #   "gitlab.com=OAuth2:${secrets.gitlab_token}"
      # ];

      accept-flake-config = true;
      auto-optimise-store = true;
    }; #end of settings

    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ]; #end of nixpath

    package = pkgs.nixVersions.stable;
  }; # end of nix block
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "24.11";
}
