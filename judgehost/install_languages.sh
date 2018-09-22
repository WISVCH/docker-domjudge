#!/bin/sh

set -eu

KOTLIN_VERSION=1.2.70

: "${LANG_C:=yes}"
: "${LANG_CPP:=yes}"
: "${LANG_JAVA:=yes}"
: "${LANG_PY2:=yes}"
: "${LANG_PY3:=yes}"
: "${LANG_KOTLIN:=yes}"

: "${LANG_CSHARP:=no}"
: "${LANG_HASKELL:=no}"
: "${LANG_PASCAL:=no}"

install_c() {
	DEB_PACKAGES="gcc $DEB_PACKAGES"
}

install_cpp() {
	DEB_PACKAGES="g++ $DEB_PACKAGES"
}

install_java() {
	DEB_PACKAGES="openjdk-8-jdk-headless $DEB_PACKAGES"
}

install_py2() {
	DEB_PACKAGES="python pypy $DEB_PACKAGES"
}

install_py3() {
	DEB_PACKAGES="python3 pypy $DEB_PACKAGES"
}

install_kotlin() {
	[ ! "$LANG_JAVA" = "yes" ] && install_java
	curl -L -o /tmp/kotlin-compiler.zip https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip
	unzip /tmp/kotlin-compiler.zip -d /opt
	rm /tmp/kotlin-compiler.zip
	echo "/opt/kotlinc/bin/kotlinc" >> /opt/bins
	echo "/opt/kotlinc/bin/kotlin" >> /opt/bins
}

install_csharp() {
	DEB_PACKAGES="mono-devel $DEB_PACKAGES"
}

install_haskell() {
	DEB_PACKAGES="ghc $DEB_PACKAGES"
}

install_pascal() {
	DEB_PACKAGES="fp-compiler $DEB_PACKAGES"
}

install_debs() {
	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get install -y --no-install-recommends $@
	apt-get autoremove -y
	apt-get clean
	rm -rf /var/lib/apt/lists/*
}

DEB_PACKAGES=""

[ "$LANG_C" = "yes" ] && install_c
[ "$LANG_CPP" = "yes" ] && install_cpp
[ "$LANG_JAVA" = "yes" ] && install_java
[ "$LANG_PY2" = "yes" ] && install_py2
[ "$LANG_PY3" = "yes" ] && install_py3
[ "$LANG_KOTLIN" = "yes" ] && install_kotlin
[ "$LANG_CSHARP" = "yes" ] && install_csharp
[ "$LANG_HASKELL" = "yes" ] && install_haskell
[ "$LANG_PASCAL" = "yes" ] && install_pascal

install_debs $DEB_PACKAGES
