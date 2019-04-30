#!/bin/bash
set -xe

: "${DOMJUDGE_DB_HOST:=db}"
: "${DOMJUDGE_DB_USER:=domjudge}"
: "${DOMJUDGE_DB_NAME:=domjudge}"

DOMJUDGE_DIR=/opt/domjudge/domserver

printf "Using\n\tDOMJUDGE_DB_HOST=%s\n\tDOMJUDGE_DB_USER=%s\n\tDOMJUDGE_DB_NAME=%s\n" $DOMJUDGE_DB_HOST $DOMJUDGE_DB_USER $DOMJUDGE_DB_NAME

if [ -z "$DOMJUDGE_TRUSTED_PROXY" ]; then
	echo >&2 "Error: missing DOMJUDGE_TRUSTED_PROXY environment variable"
	exit 1
fi
sed -i "s~DOMJUDGE_TRUSTED_PROXY~$DOMJUDGE_TRUSTED_PROXY~g" /etc/apache2/sites-available/domjudge.conf

if [ -z "$DOMJUDGE_DB_PASSWORD" ]; then
	echo >&2 "Error: missing DOMJUDGE_DB_PASSWORD environment variable"
	exit 1
fi

if [ -z "$DOMJUDGE_ADMIN_PASSWORD" ]; then
	echo >&2 "Error: missing DOMJUDGE_ADMIN_PASSWORD environment variable"
	exit 1
fi
echo "$DOMJUDGE_ADMIN_PASSWORD" > $DOMJUDGE_DIR/etc/initial_admin_password.secret
[ -f $DOMJUDGE_DIR/etc/restapi.secret ] || $DOMJUDGE_DIR/etc/genrestapicredentials > $DOMJUDGE_DIR/etc/restapi.secret

printf "dummy:%s:%s:%s:%s\n" $DOMJUDGE_DB_HOST $DOMJUDGE_DB_NAME $DOMJUDGE_DB_USER $DOMJUDGE_DB_PASSWORD > $DOMJUDGE_DIR/etc/dbpasswords.secret
sed -i "s/database_host: .*/database_host: ${DOMJUDGE_DB_HOST}/" $DOMJUDGE_DIR/webapp/app/config/parameters.yml
sed -i "s/database_name: .*/database_name: ${DOMJUDGE_DB_NAME}/" $DOMJUDGE_DIR/webapp/app/config/parameters.yml
sed -i "s/database_user: .*/database_user: ${DOMJUDGE_DB_USER}/" $DOMJUDGE_DIR/webapp/app/config/parameters.yml
sed -i "s/database_password: .*/database_password: ${DOMJUDGE_DB_PASSWORD}/" $DOMJUDGE_DIR/webapp/app/config/parameters.yml

while ! 6<>/dev/tcp/$DOMJUDGE_DB_HOST/3306; do
	echo "Waiting for MySQL server to come online"
	sleep 5
done

exec 6>&-
exec 6<&-

sed -i 's/localhost/%/g' $DOMJUDGE_DIR/bin/dj_setup_database
if ! $DOMJUDGE_DIR/bin/dj_setup_database -u $DOMJUDGE_DB_USER -p"$DOMJUDGE_DB_PASSWORD" status; then
	if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
		echo >&2 "Error: missing MYSQL_ROOT_PASSWORD environment variable"
		echo >&2 "This is only needed to setup the database once"
		exit 1
	fi
	$DOMJUDGE_DIR/bin/dj_setup_database -u root -p"$MYSQL_ROOT_PASSWORD" bare-install
fi

: "${TIMEZONE:=UTC}"

printf "date.timezone=%s\n" $TIMEZONE > /etc/php/7.0/apache2/conf.d/timezone.ini

exec "$@"
