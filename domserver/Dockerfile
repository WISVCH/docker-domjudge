FROM debian:stretch as build

ENV DOMJUDGE_VERSION 6.0.0

ENV BUILDDEPS "gcc g++ make bsdmainutils patch unzip zip \
	ca-certificates curl autoconf automake libcgroup-dev \
	php php-cli php-curl php-gmp php-mcrypt php-mysql php-mbstring php-dom composer"

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
	make configure && make composer-dependencies && \
	./configure --disable-submitclient --disable-doc-build && \
	make domserver && make install-domserver && \
	cp --remove-destination doc/logos/DOMjudgelogo.png /opt/domjudge/domserver/webapp/web/images/DOMjudgelogo.png

FROM debian:stretch

COPY --from=build /opt/domjudge /opt/domjudge

ENV RUNDEPS "apache2 php php-cli libapache2-mod-php \
	php-gd php-curl php-mysql php-json php-mbstring php-dom \
	php-zip ntp mysql-client ca-certificates unzip zip"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $RUNDEPS && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
	cd /opt/domjudge/domserver && \
	chgrp -R www-data /opt/domjudge && chmod -R g+w /opt/domjudge && \
	cp /opt/domjudge/domserver/etc/apache.conf /etc/apache2/sites-available/domjudge.conf && \
	a2enmod rewrite && a2dissite 000-default && a2ensite domjudge

EXPOSE 80

COPY start.sh /usr/local/bin/start.sh
COPY apache2-foreground.sh /usr/local/bin/apache2-foreground.sh

ENTRYPOINT ["start.sh"]
CMD ["apache2-foreground.sh"]
