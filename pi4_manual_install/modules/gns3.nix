{config, pkgs, lib, ... }:
{
	services.gns3-server = {
 		enable = true;
		auth = {
			enable = true;
			user = "gns3";
			passwordFile = "/home/nixos/.config/gns3/gns3_password";
		}; #end of auth
		ssl = {
			enable = true;
			certFile = "/home/nixos/.config/gns3/cert.pem";
			keyFile = "/home/nixos/.config/gns3/key.pem";
		};#end of ssl
		dynamips.enable = true;
		ubridge.enable	= true;
		vpcs.enable	= true;
	};#end of services.gns3
}
