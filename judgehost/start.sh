#!/bin/bash
set -e

/opt/domjudge/judgehost/bin/create_cgroups

while ! 6<>/dev/tcp/domserver/80; do
echo "Waiting for DOMserver to come online"
	sleep 5
done

exec 6>&-
exec 6<&-

exec sudo -u domjudge "$@"
