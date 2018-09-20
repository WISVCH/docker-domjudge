#!/usr/bin/env bash
set -e

: "${ADMIN_CDS_PW:=adm1n}"
: "${BALLOON_CDS_PW:=balloonPr1nter}"
: "${PUBLIC_CDS_PW:=publ1c}"
: "${PRESENTATION_CDS_PW:=presentat1on}"
: "${MYICPCP_CDS_PW:=my1cpc}"
: "${LIVE_CDS_PW:=l1ve}"

sed -i "s/password=\"admin_pw\"/password=\"${ADMIN_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml
sed -i "s/password=\"baloon_pw\"/password=\"${BALLOON_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml
sed -i "s/password=\"public_pw\"/password=\"${PUBLIC_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml
sed -i "s/password=\"presentation_pw\"/password=\"${PRESENTATION_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml
sed -i "s/password=\"icpc_pw\"/password=\"${MYICPCP_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml
sed -i "s/password=\"live_pw\"/password=\"${LIVE_CDS_PW}\"/" /opt/wlp/usr/servers/cds/users.xml

: "${DOMSERVER_USER:=feed}"
: "${CONTEST_ID:=1}"
: "${DOMSERVER_HOST:=http://domserver}"
DOMSERVER_URL="${DOMSERVER_HOST}/api/contests/${CONTEST_ID}"
if [ -z "$DOMSERVER_PASSWORD" ]; then
	echo >&2 "Error: missing DOMSERVER_PASSWORD environment variable"
	exit 1
fi

echo "using ${DOMSERVER_URL}"
sed -i "s/user=\"domjudge_user\"/user=\"${DOMSERVER_USER}\"/"                  /opt/wlp/usr/servers/cds/cdsConfig.xml
sed -i "s/password=\"domjudge_password\"/password=\"${DOMSERVER_PASSWORD}\"/"  /opt/wlp/usr/servers/cds/cdsConfig.xml
sed -i "s,url=\"contest_url\",url=\"${DOMSERVER_URL}\","                       /opt/wlp/usr/servers/cds/cdsConfig.xml
exec "$@"