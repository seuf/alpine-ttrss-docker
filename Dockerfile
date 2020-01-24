FROM alpine:edge

RUN apk --update upgrade && \
    apk add nginx php7 php7-fpm php7-mysqli php7-json php7-iconv php7-dom php7-curl php7-pcntl php7-posix php7-gd php7-pdo_mysql php7-session php7-mbstring php7-intl php7-fileinfo git mariadb-client

WORKDIR /var/www/

RUN rm -rf localhost && \
    git clone https://git.tt-rss.org/fox/tt-rss.git tt-rss

WORKDIR /var/www/tt-rss

RUN cd themes && \
    git clone https://github.com/levito/tt-rss-feedly-theme.git && \
    mv tt-rss-feedly-theme/feedly.css . && \
    mv tt-rss-feedly-theme/feedly . && \
    rm -rf tt-rss-feedly-theme

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/php-fpm.conf /etc/php7/php-fpm.conf
COPY conf/config.php /var/www/tt-rss/config.php
COPY bin/ttrss_entrypoint.sh /usr/bin/ttrss_entrypoint.sh
COPY bin/start_ttrss /sbin/start_ttrss
COPY plugins/my_custom_keys /var/www/tt-rss/plugins/my_custom_keys

RUN addgroup -S ttrss && adduser -S -G ttrss -s /bin/sh -h /var/www/tt-rss ttrss

EXPOSE 80

ENTRYPOINT ["ttrss_entrypoint.sh"] 

CMD ["start_ttrss"]
