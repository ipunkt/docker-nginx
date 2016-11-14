# nginx
docker image with nginx + php fastcgi

## Parameters
### CACHE\_DIRECTORY
The CACHE\_DIRECTORY parameter will create the given directory and set it's
permissions to 770 for www-data. This is ment to be used as cache path in your
nginx configuration file.

## Available includes
### /etc/nginx/include/harden-http-poxy.conf
Prevent the httpoxy vulnerability
### /etc/nginx/include/cors-options.conf
Set up answering an option request with a 204 CORS Header
### /etc/nginx/include/cors-php.conf
Add CORS Header for php scripts
### /etc/nginx/include/proxy-https.conf
Notify fastcgi of https usage despite ssl/tls termination at a loadbalancer.
Uses the X-FORWARDED-PROTO http header for detection.
### /etc/nginx/include/proxy-ip-rancher.conf
Sets up nginx to extract the real client ip from the X-Forwarded-For header. The
configured internal network address is 10.42.0.0/16 which is used by the rancher
managed network
