FROM debian:jessie as build

ENV DOMJUDGE_VERSION 5.1.3

ENV BUILDDEPS "gcc g++ make bsdmainutils patch unzip zip \
	linuxdoc-tools linuxdoc-tools-text ca-certificates \
	groff texlive-latex-recommended texlive-latex-extra \
	texlive-fonts-recommended texlive-lang-dutch curl autoconf automake"

COPY apache.conf.in /tmp/apache.conf.in
COPY patches /tmp/patches

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	mkdir -p /src && \
	curl -L -o /src/domjudge-${DOMJUDGE_VERSION}.zip https://github.com/DOMjudge/domjudge/archive/${DOMJUDGE_VERSION}.zip && \
	unzip /src/domjudge-${DOMJUDGE_VERSION}.zip -d /src && \
	cd /src/domjudge-${DOMJUDGE_VERSION} && \
	mv /tmp/apache.conf.in etc/apache.conf.in && \
	for patch in /tmp/patches/*.patch; do patch -p1 -i $patch; done && \
	make configure && /src/domjudge-${DOMJUDGE_VERSION}/configure --disable-submitclient && make domserver && make install-domserver

FROM debian:jessie

COPY --from=build /opt/domjudge /opt/domjudge

ENV RUNDEPS "apache2 php5 php5-cli libapache2-mod-php5 \
	php5-gd php5-curl php5-mysql php5-json \
	ntp mysql-client ca-certificates unzip zip"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $RUNDEPS && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
	cd /opt/domjudge/domserver && \
	chgrp -R www-data /opt/domjudge && chmod -R g+w /opt/domjudge && \
	cp /opt/domjudge/domserver/etc/apache.conf /etc/apache2/sites-available/domjudge.conf && a2dissite 000-default && a2ensite domjudge

EXPOSE 80

COPY start.sh /usr/local/bin/start.sh
COPY apache2-foreground.sh /usr/local/bin/apache2-foreground.sh

ENTRYPOINT ["start.sh"]
CMD ["apache2-foreground.sh"]
