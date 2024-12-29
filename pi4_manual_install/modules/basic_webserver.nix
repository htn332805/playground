{ config, pkgs, lib, ... }:

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."home_nginx.com" = {
    root = "/var/www/home_nginx.com";
  };#end of nginx virtualhost
}
