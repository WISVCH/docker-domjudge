#!/bin/bash
set -e

: "${DOMSERVER_HOST:=http://domserver}"
DOMSERVER_URL="${DOMSERVER_HOST}/api/v4"
: "${DOMSERVER_USER:=judgehost}"

if [ -z "$DOMSERVER_PASSWORD" ]; then
	echo >&2 "Error: missing DOMSERVER_PASSWORD environment variable"
	exit 1
fi

printf "default\t%s\t%s\t%s\n" $DOMSERVER_URL $DOMSERVER_USER $DOMSERVER_PASSWORD > /opt/domjudge/judgehost/etc/restapi.secret

/opt/domjudge/judgehost/bin/create_cgroups
exec sudo -u domjudge "$@"
