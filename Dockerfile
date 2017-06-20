FROM alpine:edge
RUN apk update
RUN apk upgrade
RUN apk add nginx php5-fpm php5-mysqli php5-json php5-iconv php5-dom php5-curl php5-pcntl php5-posix php5-gd git mariadb-client
# RUN apk add nginx php7-fpm php7-mysqli php7-json php7-iconv php7-dom php7-curl php7-pcntl php7-posix php7-gd php7-session php7-mbstring git
WORKDIR /var/www/
RUN rm -rf localhost && \
    git clone https://tt-rss.org/git/tt-rss.git tt-rss

WORKDIR /var/www/tt-rss
RUN cd themes && \
    git clone https://github.com/levito/tt-rss-feedly-theme.git
RUN cd themes && \
    mv tt-rss-feedly-theme/feedly.css . && \
    mv tt-rss-feedly-theme/feedly . && \
    rm -rf tt-rss-feedly-theme

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/php-fpm.conf /etc/php5/php-fpm.conf
COPY conf/config.php /var/www/tt-rss/config.php
COPY bin/ttrss_entrypoint.sh /usr/bin/ttrss_entrypoint.sh
COPY bin/start_ttrss /sbin/start_ttrss
COPY plugins/my_custom_keys /var/www/tt-rss/plugins/my_custom_keys

EXPOSE 80

ENTRYPOINT ["ttrss_entrypoint.sh"] 

CMD ["start_ttrss"]
