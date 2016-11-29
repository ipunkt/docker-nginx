FROM nginx:1.10.2

ADD start.sh /start.sh
CMD [ "sh", "/start.sh" ]
RUN rm /etc/nginx/conf.d/*

# This file is used by the start script to substite Templates
#
# Currently known Templates:
# SERVER_URL: served url
COPY laravel.conf.tpl /etc/nginx/conf.template.d/999-laravel.conf.tpl
RUN mkdir -p /var/www/app

ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive


ENV LC_ALL=C
ENV LANG=C
RUN gpg --keyserver keys.gnupg.net --recv-key 89DF5277 && gpg -a --export 89DF5277 \
			| apt-key add - && \
			echo "deb http://ftp.hosteurope.de/mirror/packages.dotdeb.org/ jessie all" \
						> /etc/apt/sources.list.d/dotdeb.list
RUN apt-get update && apt-cache search php7 && apt-get -y install php7.0-mysql \
		coreutils php7.0-fpm php7.0-json php7.0-mbstring \
		php7.0-xml php7.0-zip \
		php7.0-cli php7.0-curl mysql-client locales \
		&& rm -Rf /var/lib/apt/lists
RUN locale-gen de_DE.UTF-8 && dpkg-reconfigure locales
ENV LC_ALL=de_DE.UTF-8
ENV LANG=de_DE.UTF-8

# Has to be after the installation or dpkg tries to ask about the existing file
ADD www.conf /etc/php/7.0/fpm/pool.d/

COPY include /etc/nginx/include
