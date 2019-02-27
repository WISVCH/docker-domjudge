FROM debian:stretch as build

ENV CDS_VERSION 2.0.1797
ENV PRESENTATION_VERSION 2.0.1797

ENV BUILDDEPS "unzip ca-certificates curl"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	curl -L -o /opt/wlp.CDS-${CDS_VERSION}.zip https://icpc.baylor.edu/icpctools/CDS/wlp.CDS-${CDS_VERSION}.zip && \
	unzip /opt/wlp.CDS-${CDS_VERSION}.zip -d /opt && \
	curl -l -o /opt/presentations-${PRESENTATION_VERSION}.zip https://icpc.baylor.edu/icpctools/pres/presentations-${PRESENTATION_VERSION}.zip && \
	unzip /opt/presentations-${PRESENTATION_VERSION}.zip -d /opt && \
	mkdir -p /contest/present && \
	cp /opt/presentations-2.0/lib/presentContest.jar /contest/present

FROM debian:stretch

COPY --from=build /opt/wlp /opt/wlp
COPY --from=build /contest/present /contest/present

ENV RUNDEPS "openjdk-8-jdk-headless"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $RUNDEPS && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY photos/ /contest/present/photos

COPY users.xml /opt/wlp/usr/servers/cds/users.xml
COPY cdsConfig.xml /opt/wlp/usr/servers/cds/cdsConfig.xml
COPY server.xml /opt/wlp/usr/servers/cds/server.xml

EXPOSE 443

COPY start.sh /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
CMD /opt/wlp/bin/server run cds
