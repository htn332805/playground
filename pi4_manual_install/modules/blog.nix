{ config, pkgs, lib, ... }:

{
  services.nginx.virtualHosts."blog_home_nginx.com" = {
    root = "/var/www/bog_home_nginx.com";
  };
}
