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
export PHP_PASS=${PHP_PASS:-phpfpm:9000}
export PING_ENDPOINT=${PING_ENDPOINT:-FALSE}
export PHP_REMOVE=${PHP_REMOVE:-FALSE}
export NGINX_DNS_RESOLVER=${NGINX_DNS_RESOLVER:-127.0.0.11}

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

# Check MySQL Connection
if [ "$DB_HOST" = "" -o "$DB_USERNAME" = "" -o "$DB_PASSWORD" = "" ]
then
	echo "DB_HOST, DB_USERNAME or DB_PASSWORD not set, continueing without waiting for database."
	echo "Please set DB_HOST DB_USERNAME and DB_PASSWORD to enable database wait"
else
	echo "Waiting for Database connection on $DB_HOST"
	mysql -h $DB_HOST -u $DB_USERNAME "--password=$DB_PASSWORD" -e exit
	while [ "$?" != "0" ]
	do echo "Waiting 5s until next try to"
		sleep 5s
		mysql -h $DB_HOST -u $DB_USERNAME "--password=$DB_PASSWORD" -e exit
	done
fi

# This command causes the script to fail if any command exits with a status != 0
# In effect if any command fails then the container will stop - a visual
# indication that something has gone wrong
set -e

/usr/local/bin/confd -onetime -backend env

echo Starting NGINX
nginx -g "daemon off;"
echo "Webserver has stopped"
