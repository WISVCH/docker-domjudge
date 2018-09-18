#!/bin/bash
set -e

: "${DOMJUDGE_DB_HOST:=db}"
: "${DOMJUDGE_DB_USER:=domjudge}"
: "${DOMJUDGE_DB_NAME:=domjudge}"

printf "Using\n\tDOMJUDGE_DB_HOST=%s\n\tDOMJUDGE_DB_USER=%s\n\tDOMJUDGE_DB_NAME=%s\n" $DOMJUDGE_DB_HOST $DOMJUDGE_DB_USER $DOMJUDGE_DB_NAME

if [ -z "$DOMJUDGE_DB_PASSWORD" ]; then
	echo >&2 "Error: missing DOMJUDGE_DB_PASSWORD environment variable"
	exit 1
fi


printf "dummy:%s:%s:%s:%s\n" $DOMJUDGE_DB_HOST $DOMJUDGE_DB_NAME $DOMJUDGE_DB_USER $DOMJUDGE_DB_PASSWORD > /opt/domjudge/domserver/etc/dbpasswords.secret
sed -i "s/database_host: .*/database_host: ${DOMJUDGE_DB_HOST}/" /opt/domjudge/domserver/webapp/app/config/parameters.yml
sed -i "s/database_name: .*/database_name: ${DOMJUDGE_DB_NAME}/" /opt/domjudge/domserver/webapp/app/config/parameters.yml
sed -i "s/database_user: .*/database_user: ${DOMJUDGE_DB_USER}/" /opt/domjudge/domserver/webapp/app/config/parameters.yml
sed -i "s/database_password: .*/database_password: ${DOMJUDGE_DB_PASSWORD}/" /opt/domjudge/domserver/webapp/app/config/parameters.yml

while ! 6<>/dev/tcp/$DOMJUDGE_DB_HOST/3306; do
	echo "Waiting for MySQL server to come online"
	sleep 5
done

exec 6>&-
exec 6<&-

sed -i 's/localhost/%/g' /opt/domjudge/domserver/bin/dj_setup_database
if ! /opt/domjudge/domserver/bin/dj_setup_database -u $DOMJUDGE_DB_USER -p"$DOMJUDGE_DB_PASSWORD" status; then
	if [ -z "$DOMJUDGE_DB_ROOT_PASSWORD" ]; then
		echo >&2 "Error: missing DOMJUDGE_DB_ROOT_PASSWORD environment variable"
		echo >&2 "This is only needed to setup the database once"
		exit 1
	fi
	/opt/domjudge/domserver/bin/dj_setup_database -u root -p"$DOMJUDGE_DB_ROOT_PASSWORD" bare-install
fi

: "${TIMEZONE:=UTC}"

printf "date.timezone=%s\n" $TIMEZONE > /etc/php/7.0/apache2/conf.d/timezone.ini

exec "$@"
