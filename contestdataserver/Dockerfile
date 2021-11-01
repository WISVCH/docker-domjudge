FROM debian:stretch

ENV CDS_VERSION 2.2.386

ENV BUILDDEPS "unzip ca-certificates curl openjdk-8-jdk-headless"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	curl -k -L -o /opt/wlp.CDS-${CDS_VERSION}.zip https://github.com/icpctools/builds/releases/download/v${CDS_VERSION}/wlp.CDS-${CDS_VERSION}.zip && \
	unzip /opt/wlp.CDS-${CDS_VERSION}.zip -d /opt && \
	mkdir /contest &&apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY photos/  /opt/wlp/usr/servers/cds/config/present/photos
COPY images/  /opt/wlp/usr/servers/cds/config/present/build
COPY promo/  /opt/wlp/usr/servers/cds/config/present/promo
COPY assets/  /contest/config/
COPY users.xml /opt/wlp/usr/servers/cds/users.xml
COPY cdsConfig.xml /opt/wlp/usr/servers/cds/config/cdsConfig.xml
EXPOSE 8080
EXPOSE 8443
COPY start.sh /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
CMD /opt/wlp/bin/server run cds
