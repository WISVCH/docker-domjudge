FROM debian:stretch

ENV CDS_VERSION 2.1.2100

ENV BUILDDEPS "unzip ca-certificates curl openjdk-8-jdk-headless"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	curl -k -L -o /opt/wlp.CDS-${CDS_VERSION}.zip https://pc2.ecs.csus.edu/pc2projects/build/CDS/dist/wlp.CDS-${CDS_VERSION}.zip && \
	unzip /opt/wlp.CDS-${CDS_VERSION}.zip -d /opt && \
	mkdir /contest &&apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY photos/ /contest/present/photos
COPY users.xml /opt/wlp/usr/servers/cds/users.xml
COPY cdsConfig.xml /opt/wlp/usr/servers/cds/config/cdsConfig.xml
EXPOSE 8080
EXPOSE 8443
COPY start.sh /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
CMD /opt/wlp/bin/server run cds
