#!/bin/sh
set -e

if [ -z "$TTRSS_DB_HOST" ]; then
    echo >&2 'error: missing required TTRSS_DB_HOST environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi
if [ -z "$TTRSS_DB_PORT" ]; then
    echo >&2 'error: missing required TTRSS_DB_PORT environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi
if [ -z "$TTRSS_DB_NAME" ]; then
    echo >&2 'error: missing required TTRSS_DB_NAME environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi
if [ -z "$TTRSS_DB_USER" ]; then
    echo >&2 'error: missing required TTRSS_DB_USER environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi
if [ -z "$TTRSS_DB_PASS" ]; then
    echo >&2 'error: missing required TTRSS_DB_PASS environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi
if [ -z "$TTRSS_SELF_URL_PATH" ]; then
    echo >&2 'error: missing required TTRSS_SELF_URL_PATH environment variable'
    echo >&2 '  Did you forget to --link some-mysql-container:mysql?'
    exit 1
fi


sed -i "s/TTRSS_DB_HOST/${TTRSS_DB_HOST}/" /var/www/tt-rss/config.php
sed -i "s/TTRSS_DB_PORT/${TTRSS_DB_PORT}/" /var/www/tt-rss/config.php
sed -i "s/TTRSS_DB_NAME/${TTRSS_DB_NAME}/" /var/www/tt-rss/config.php
sed -i "s/TTRSS_DB_USER/${TTRSS_DB_USER}/" /var/www/tt-rss/config.php
sed -i "s/TTRSS_DB_PASS/${TTRSS_DB_PASS}/" /var/www/tt-rss/config.php
sed -i "s/TTRSS_SELF_URL_PATH/${sTTRSS_SELF_URL_PATH}/" /var/www/tt-rss/config.php


if [ ! -f /usr/bin/php ]; then
  ln -s /usr/bin/php5 /usr/bin/php
fi

_ensure_mysql_running() {
    #Checking mysql is running (Thank you to Sameersbn)
    timeout=60
    while ! mysql -h$TTRSS_DB_HOST -u$TTRSS_DB_USER -p$TTRSS_DB_PASS $TTRSS_DB_NAME -e "SHOW TABLES" > /dev/null 2>&1
    do
        timeout=$(($timeout -1))
        if [[ $timeout -eq 0 ]]; then
            echo -e "\nCould not connect to database server. Aborting..."
  #          exit 1
        fi
        echo -n "."
        sleep 1
    done
}

echo "Waiting for mysql (${TTRSS_DB_USER}@${TTRSS_DB_HOST}:${TTRSS_DB_NAME})"
_ensure_mysql_running

tables_exists=$(mysql -h$TTRSS_DB_HOST -u$TTRSS_DB_USER -p$TTRSS_DB_PASS $TTRSS_DB_NAME -e "SHOW TABLES")
if [ "${tables_exists}" == "" ]; then
    echo "Creating ttrss Schema"
    mysql -h$TTRSS_DB_HOST -u$TTRSS_DB_USER -p$TTRSS_DB_PASS $TTRSS_DB_NAME < /var/www/tt-rss/schema/ttrss_schema_mysql.sql
fi

exec "$@"
