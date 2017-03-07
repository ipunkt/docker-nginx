# nginx
docker image with nginx + php fastcgi

## Parameters
### CACHE\_DIRECTORY
The CACHE\_DIRECTORY parameter will create the given directory and set it's
permissions to 770 for www-data. This is ment to be used as cache path in your
nginx configuration file.
### NO\_FPM
The NO\_FPM parameter will prevent the php7 fpm from being started. You will
have to provide a php-fpm socket mounted to /var/run/php/php-fpm.sock via
volumes\_from to use php with this option
### NO\_MIGRATE & NO\_SEED
The NO\_MIGRATE & NO\_SEED parameters will prevent `artisan migrate` and
`artisan seed` from being run despite an artisan file being present.
### USER\_ID + GROUP\_ID
Makes the nginx and php-fpm run under these ids. Useful when using the image
for local development
### PHP\_MAX\_CHILDREN
PHP configuration value: pm.max\_chilren. Defaults to 100
### PHP\_START\_SERVERS
PHP Configuration value: pm.start\_servers
### PHP\_MIN\_SPARE\_SERVERS
PHP Configuration value: pm.min\_spare\_servers
### PHP\_MAX\_SPARE\_SERVERS
PHP Configuration value: pm.max\_spare\_servers

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
