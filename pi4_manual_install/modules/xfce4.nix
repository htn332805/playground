{ config, pkgs, lib, ... }:
{
  services.xserver = {
	enable = true;
	displayManager.lightdm.enable = true;
	desktopManager.xfce.enable = true;

	windowManager.qtile.enable = true;
	windowManager.qtile.backend = "x11";
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
}
