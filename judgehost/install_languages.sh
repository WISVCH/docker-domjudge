#!/bin/sh

set -eu

install_py2() {
	DEB_PACKAGES="python pypy $DEB_PACKAGES"
	CHROOT_PACKAGES="python $DEB_PACKAGES"
}


install_kotlin() {
  # Package is downloaded and unzipped by docker file, just create links for path
  # Directory matters, e.g. installing in /opt fails
	ln -s  /usr/local/lib/kotlinc/bin/kotlinc /usr/bin/kotlinc
	ln -s  /usr/local/lib/kotlinc/bin/kotlin /usr/bin/kotlin
	# copy full kotlin distribution
	cp -r usr/local/lib/kotlinc ${CHROOT}/usr/local/lib/
	# remove kotlinx jars since they are not allowed during contest
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/kotlinx*.jar
	# remove unessecary jars
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/kotlin-test*.jar
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/kotlin-annotation*.jar
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/android*.jar
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/ktor*.jar
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/*compiler*.jar
	rm  ${CHROOT}/usr/local/lib/kotlinc/lib/js*.jar
	/opt/domjudge/judgehost/bin/dj_run_chroot "ln -s /usr/local/lib/kotlinc/bin/kotlin /usr/bin/kotlin && ln -s /usr/local/lib/kotlinc/bin/kotlinc /usr/bin/kotlinc"
}

install_csharp() {
	DEB_PACKAGES="mono-devel $DEB_PACKAGES"
	CHROOT_PACKAGES="mono-runtime $DEB_PACKAGES"
}


install_debs() {
  # execute commands in chroot
  /opt/domjudge/judgehost/bin/dj_run_chroot "export DEBIAN_FRONTEND=noninteractive &&
  apt-get update &&
	apt-get install -y --no-install-recommends --no-install-suggests ${CHROOT_PACKAGES} &&
	apt-get autoremove -y &&
	apt-get clean &&
	rm -rf /var/lib/apt/lists/* &&
	rm -rf /tmp/*"
	#execute command on home root
	apt-get update &&
	apt-get install -y --no-install-recommends --no-install-suggests ${DEB_PACKAGES} &&
	apt-get autoremove -y &&
	apt-get clean &&
	rm -rf /var/lib/apt/lists/* &&
	rm -rf /tmp/*
}

DEB_PACKAGES=""
CHROOT_PACKAGES=""
[ "$LANG_PY2" = "yes" ] && install_py2
[ "$LANG_CSHARP" = "yes" ] && install_csharp
[ "$LANG_KOTLIN" = "yes" ] && install_kotlin

# Enable networking in chroot
mv ${CHROOT}/etc/resolv.conf ${CHROOT}/etc/resolve.conf.bak
cp /etc/resolv.conf ${CHROOT}/etc

[ "$DEB_PACKAGES" != "" ] && install_debs

# Restore original state
mv ${CHROOT}/etc/resolve.conf.bak ${CHROOT}/etc/resolve.conf
