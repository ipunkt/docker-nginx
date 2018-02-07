# nginx
docker image with nginx

## Legacy Support
PHP7.0 was removed from this image because maintaining different versions in ipunktbs/php and a single nginx version is
easier than creating different versions of this image.

The following Feautures have been removed because of this:
- artisan migrate & artisan db:seed: Required PHP
- initscript & startscript: Used to prepare for php
- Reown Storage: Used to prepare for php
- wait for database: only done to prepare for artisan migrate & artisan db:seed
### Replacing those functions
To use these functions in the future create a start-once / restart:never container running the given command.
Waiting for the database is not required. A healthcheck should be used instead where the application can decide itself
what conditions to check.

## Parameters
### PHP\_PASS
Defaults to: `backend`
Set the `fastcgi_pass` for php files
### BACKEND\_HOST
Defaults to: `phpfpm:9000`
This host is added as `upstream backend`. Can be used, for example, for `PHP_PASS`
### BACKEND\_MAX\_FAILS
Defaults to: `0`
Set the maximum fails before the backend host is marked as failed
### DNS\_RESOLVER
Defaults to: `cat /etc/resolv.conf | grep nameserver | awk '{ print $2; }'` - first `nameserver` entry in /etc/resolv.conf
Set the dns server which is used to resolve the hostname
### DNS\_VALID
Defaults to: `30s`
Sets the amount of time a dns resolution for a host is cached.
### PHP\_REMOVE
Defaults to `FALSE`
If set to `TRUE` it removes the php configuration from the laravel.conf nginx config. Allows to start
the server without a php-fpm to connect to
### PING\_ENDPOINT
Defaults to `FALSE`
If set to `TRUE` it adds `/ping` as endpoint to the php-fpm ping function
### CACHE\_DIRECTORY
The CACHE\_DIRECTORY parameter will create the given directory and set it's
permissions to 770 for www-data. This is ment to be used as cache path in your
nginx configuration file.
### USER\_ID + GROUP\_ID
Makes the nginx and php-fpm run under these ids. Useful when using the image
for local development

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
