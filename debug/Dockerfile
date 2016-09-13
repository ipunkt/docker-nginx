FROM ipunktbs/laravel-nginx:${SOURCE_BRANCH}
RUN apt-get update && apt-get -y install php7.0-xdebug \
		&& rm -Rf /var/lib/apt/lists
COPY 30-xdebug.ini /etc/php/7.0/fpm/conf.d/
