FROM debian:stretch as build

ENV DOMJUDGE_VERSION 7.0.0

ENV BUILDDEPS "make curl autoconf automake patch gcc g++ ca-certificates libcgroup-dev unzip git \
	php php-cli php-curl php-gd php-intl php-zip php-gmp php-mcrypt php-mysql php-mbstring php-dom composer"

COPY patches /tmp/patches

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS && \
	cd /tmp && \
	groupadd -g 2000 domjudge && \
	useradd -u 2000 -g 2000 -d / -s /bin/false domjudge && \
	mkdir -p /src && \
	curl -L -o /src/domjudge-${DOMJUDGE_VERSION}.zip https://github.com/DOMjudge/domjudge/archive/${DOMJUDGE_VERSION}.zip && \
	unzip /src/domjudge-${DOMJUDGE_VERSION}.zip -d /src && \
	cd /src/domjudge-${DOMJUDGE_VERSION} && \
	for patch in /tmp/patches/*.patch; do patch -p1 -i $patch; done && \
	make configure && make composer-dependencies && /src/domjudge-${DOMJUDGE_VERSION}/configure --with-domjudge-user=domjudge --disable-submitclient && make judgehost && make install-judgehost

FROM debian:stretch

ENV RUNDEPS "unzip curl php-cli php-curl php-json procps sudo ca-certificates libcgroup-dev"

COPY --from=build /opt/domjudge /opt/domjudge

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends $RUNDEPS && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
	groupadd -g 2000 domjudge && \
	useradd -u 2000 -g 2000 -d / -s /bin/false domjudge && \
	useradd -d / -U -s /bin/false domjudge-run && \
	cd /opt/domjudge/judgehost && \
	chown -R domjudge judgings lib log run tmp && \
	cp /opt/domjudge/judgehost/etc/sudoers-domjudge /etc/sudoers.d/ && \
	chmod 440 /etc/sudoers.d/sudoers-domjudge && visudo -c && \
	sed -i 's/true/false/g' /opt/domjudge/judgehost/etc/judgehost-config.php

COPY install_languages.sh /tmp/install_languages.sh
COPY languages /tmp/languages

RUN . /tmp/languages && /tmp/install_languages.sh && \
	rm /tmp/install_languages.sh && rm /tmp/languages

COPY start.sh /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
CMD ["/opt/domjudge/judgehost/bin/judgedaemon"]
