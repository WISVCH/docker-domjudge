#!/bin/bash
set -e

: "${DOMSERVER_HOST:=http://domserver}"
# Don't use api version numbers in this url, else you will get state errors.
DOMSERVER_URL="${DOMSERVER_HOST}/api"
: "${CONTEST_ID:=1}"
echo "Using contest id: ${CONTEST_ID}"
if [ -z "$DOMSERVER_PASSWORD" ]; then
	echo >&2 "Error: missing DOMSERVER_PASSWORD environment variable"
	exit 1
fi

printf "default\t%s\t%s\t%s\n" $DOMSERVER_URL $DOMSERVER_USER $DOMSERVER_PASSWORD >/opt/domjudge/domserver/etc/restapi.secret

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

exec "$@"
