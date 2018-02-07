#!/bin/sh

INITLOCK="/var/init.lock"

export USER="www-data"
if [ ! -z "$USER_ID" -a ! -z "$GROUP_ID" ] ; then
	echo "Switching to user"
	export USER="user"
	deluser "$USER"
	delgroup "$USER"
	addgroup --gid "$GROUP_ID" "$USER"
	adduser --disabled-password --disabled-login --no-create-home --system --uid "$USER_ID" --gid "$GROUP_ID" "$USER"
fi

if [ -d "/opt/confd/conf.d" ] ; then
	cp -R /opt/confd/conf.d/* /etc/confd/conf.d/
fi

if [ -d "/opt/confd/templates" ] ; then
	cp -R /opt/confd/templates/* /etc/confd/tempaltes/
fi

#
# Set default values
#
export NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE:-32m}
export SERVER_URL=${SERVER_URL:-localhost}
export PHP_PASS=${PHP_PASS:-backend}
export BACKEND_HOST=${BACKEND_HOST:-phpfpm:9000}
export BACKEND_MAX_FAILS=${BACKEND_MAX_FAILS:-0}
export PING_ENDPOINT=${PING_ENDPOINT:-FALSE}
export PHP_REMOVE=${PHP_REMOVE:-FALSE}
export DNS_RESOLVER=${DNS_RESOLVER:-$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2; }')}
export DNS_VALID=${DNS_VALID:-10s}

if [ ! -z "$CACHE_DIRECTORY" ] ; then
	if [ ! -d "$CACHE_DIRECTORY" ] ; then
		echo "Creating Cache Directory"
		mkdir -p "$CACHE_DIRECTORY"
	fi
	echo "Setting Ownership for Cache directory $CACHE_DIRECTORY"
	chown -R $USER.$USER "$CACHE_DIRECTORY"
	echo "Setting permissions for Cache directory $CACHE_DIRECTORY"
	chmod -R 770 "$CACHE_DIRECTORY"
fi

# This command causes the script to fail if any command exits with a status != 0
# In effect if any command fails then the container will stop - a visual
# indication that something has gone wrong
set -e

if [ -d /etc/nginx/conf.template.d ] ; then
	cp -R /etc/nginx/conf.template.d/* /etc/nginx/conf.d/
else
	/usr/local/bin/confd -onetime -backend env
fi

echo Starting NGINX
nginx -g "daemon off;"
echo "Webserver has stopped"
