FROM debian:stretch
ENV CDS_VERSION 2.0.1797
ENV PRESENTATION_VERSION 2.0.1797
ENV BUILDDEPS "patch unzip zip ca-certificates curl openjdk-8-jdk-headless"
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	mkdir -p /opt && \
	curl -L -o /opt/wpl.CDS-${CDS_VERSION}.zip https://icpc.baylor.edu/icpctools/CDS/wlp.CDS-${CDS_VERSION}.zip && \
	unzip /opt/wpl.CDS-${CDS_VERSION}.zip -d /opt
# Downlaod the presentContest.jar
RUN curl -l -o /opt/presentations-${PRESENTATION_VERSION}.zip https://icpc.baylor.edu/icpctools/pres/presentations-${PRESENTATION_VERSION}.zip && \
    unzip /opt/presentations-${PRESENTATION_VERSION}.zip -d /opt &&\
    mkdir -p /contest/present &&\
    cp /opt/presentations-2.0/lib/presentContest.jar /contest/present
EXPOSE 8443
COPY start.sh /usr/local/bin/start.sh
COPY users.xml /opt/wlp/usr/servers/cds/users.xml
COPY cdsConfig.xml /opt/wlp/usr/servers/cds/cdsConfig.xml
COPY server.xml /opt/wlp/usr/servers/cds/server.xml
ENTRYPOINT ["start.sh"]
CMD /opt/wlp/bin/server run cds
COPY photos/ /contest/present/photos

