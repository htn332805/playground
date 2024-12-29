{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
	git neovim htop tmux screen tree nload curl nb freeplane wget xrdp x11vnc wget obsidian nload neofetch
	nnn				# terminal file manager
    	ripgrep 		# recursively searches directories for a regex pattern
    	jq 			# A lightweight and flexible command-line JSON processor
    	yq-go 			# yaml processor https://github.com/mikefarah/yq
    	eza 			# A modern replacement for ‘ls’
    	fzf 			# A command-line fuzzy finder
	dnsutils  		# `dig` + `nslookup`
    	ldns 			# replacement of `dig`, it provide the command `drill`
    	aria2 			# A lightweight multi-protocol & multi-source command-line download utility
    	socat 			# replacement of openbsd-netcat
    	nmap 			# A utility for network discovery and security auditing
    	ipcalc  		# it is a calculator for the IPv4/v6 addresses
    	mtr 			# A network diagnostic tool
	hugo 			# static site generator
    	glow 			# markdown previewer in terminal
    	btop  			# replacement of htop/nmon
    	iotop 			# io monitoring
    	iftop 			# network monitoring
    	strace 			# system call monitoring
    	ltrace 			# library call monitoring
    	lsof 			# list open files
	lm_sensors 		# for `sensors` command
	pciutils 		# lspci
    	usbutils 		# lsusb
	zip xz unzip p7zip iperf3 fio cowsay file which tree gnused gnutar gawk zstd gnupg nix-output-monitor
	sysstat ethtool dwm 

	(python3.withPackages(ps: with ps; [ 
		pandas 
		requests
		numpy
		scipy
		matplotlib
		flask
		jupyterlab
		qtile
		qtile-extras
		dash pip
	])) #end of python packages

  ]; #end of packages list


}
