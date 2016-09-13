# nginx
docker image with nginx + php fastcgi

## Available includes
### /etc/nginx/include/harden-http-poxy.conf
Prevent the http poxy vulnerability
### /etc/nginx/include/cors-options.conf
Set up answering an option request with a 204 CORS Header
### /etc/nginx/include/cors-php.conf
Add CORS Header for php scripts
### /etc/nginx/include/proxy-https.conf
Notify fastcgi of https usage despite ssl/tls termination at a loadbalancer.
Uses the X-FORWARDED-PROTO http header for detection.
