#!/bin/sh

PATH="/var/www/app"

for STORAGE in "${PATH}/storage" "${PATH}/app/storage" ; do
	if [ -d $STORAGE ] ; then
		echo Making $STORAGE writable
		chmod -R 777 $STORAGE
	else
		echo Storage $STORAGE not found
	fi
done

if [ x"$SERVER_URL" = x"" ] ; then
	SERVER_URL=localhost
fi

echo Creating NGINX Configuration
echo "Setting Server Url to $SERVER_URL"
for FILEPATH in /etc/nginx/conf.template.d/*
do FILENAME=$(basename $FILEPATH | sed -e 's/\.tpl//')
sed -e 's/<SERVER_URL>/'$SERVER_URL'/g' "$FILEPATH" > "/etc/nginx/conf.d/$FILENAME"
done

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

ARTISAN="${PATH}/artisan "

if [ -f $ARTISAN ] ; then
	echo Taking Application into maintenance mode
	php $ARTISAN down
else
	echo "Artisan not found at $ARTISAN: skipping maintenance mode"
fi

echo Starting PHP7 fpm
/etc/init.d/php7.0-fpm start

echo Starting NGINX
nginx -g "daemon off;" &

if [ -f $ARTISAN ] ; then
	echo Migrating
	php ${PATH}/artisan migrate --no-interaction --force

	echo Seeding
	php ${PATH}/artisan db:seed --no-interaction --force

	echo Taking Application out of maintenance mode
	php ${PATH}/artisan up
else
	echo "Artisan not found at $ARTISAN: skipping migrate and seed"
fi

echo "Entering main-wait for the webserver"
wait

echo "Webserver has stopped"
