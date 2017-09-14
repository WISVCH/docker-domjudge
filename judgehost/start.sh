#!/bin/bash
set -e

: "${DOMSERVER_HOST:=http://domserver/api}"
: "${DOMSERVER_USER:=judgehost}"
DOMSERVER_HOSTNAME_API="hostname?judgehost=true"

if [ -z "$DOMSERVER_PASSWORD" ]; then
	echo >&2 "Error: missing DOMSERVER_PASSWORD environment variable"
	exit 1
fi

printf "default\t%s\t%s\t%s\n" $DOMSERVER_HOST $DOMSERVER_USER $DOMSERVER_PASSWORD > /opt/domjudge/judgehost/etc/restapi.secret

id=$(curl -s -L "$DOMSERVER_HOST/$DOMSERVER_HOSTNAME_API")
if echo $id | egrep -q '^[0-9]+$'; then
	echo "Setting hostname to judgehost$id"
	hostname "judgehost$id"
	grep -q "127.0.1.1\sjudgehost$id" /etc/hosts || echo "Setting entry in /etc/hosts" && echo -e "127.0.1.1\tjudgehost$id" >> /etc/hosts
else
	echo >&2 "API response was not a number"
fi

/opt/domjudge/judgehost/bin/create_cgroups
exec sudo -u domjudge "$@"
