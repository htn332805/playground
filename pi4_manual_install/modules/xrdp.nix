{ config, pkgs, lib, ... }:

{
	services.xrdp.enable = true;
	services.xrdp.audio.enable = true;
	services.xrdp.sslKey = "/home/nixos/.config/xrdp/key.pem";
	services.xrdp.sslCert = "/home/nixos/.config/xrdp/cert.pem";
	services.xrdp.openFirewall = true;
	services.xrdp.defaultWindowManager = "starxfce4";
	services.xrdp.extraConfDirCommands = ''
		substituteInPlace $out/sesman.ini \
			--replace LogLevel=INFO LogLevel=DEBUG \
			--replace LogFile=/dev/null LogFile=/var/log/xrdp.log
	'';
}
