upstream backend {
    server {{ getenv "BACKEND_HOST" }};
}

server {

	listen 80 default_server;
	listen 81 default_server http2 proxy_protocol;
	listen [::]:80 default_server ipv6only=on;
	client_max_body_size {{ getenv "NGINX_CLIENT_MAX_BODY_SIZE" }};

	root /var/www/app/public;
	index index.php index.html index.htm;

	server_name {{ getenv "SERVER_URL" }};

	include /etc/nginx/server.d/*.conf;

	location / {
		include /etc/nginx/include/cors-options.conf;

		try_files $uri $uri/ /index.php$is_args$args;
	}

	{{ if eq (getenv "PING_ENDPOINT") "TRUE" }}
	location /ping {
		access_log off;
		include fastcgi_params;
		fastcgi_index ping;
		fastcgi_pass {{ getenv "PHP_PASS" }};
		fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
	}
	{{ end }}

	{{ if ne (getenv "PHP_REMOVE") "TRUE" }}
	location ~ \.php$ {
		include /etc/nginx/include/cors-php.conf;

		try_files $uri /index.php =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass {{ getenv "PHP_PASS" }};
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
		include /etc/nginx/include/proxy-https.conf;
		include /etc/nginx/include/proxy-ip-rancher.conf;
		include /etc/nginx/include/harden-http-poxy.conf;
	}
	{{ end }}
}

