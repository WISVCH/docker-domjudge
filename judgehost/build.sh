#!/bin/bash

set -e

DEFAULT_VERSION=7.3.3
KOTLIN_VERSION=1.5.31
VERSION=$1
if [ -z ${VERSION} ]
then
  echo "Falling back to default version $DEFAULT_VERSION"
	echo "Usage: $0 domjudge-version"
	echo "	For example: $0 5.3.0"
	VERSION=${DEFAULT_VERSION}
fi

if [ ! -d kotlinc ]; then
  # cheat so there is no need to install curl and unzip the image and faster when fine tuning
  echo "Downloading kotlin distribution"
  curl -o kotlin-compiler.zip -L https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip
  unzip  kotlin-compiler.zip
fi

# To add packages in chroot we need to run in privileged mode and this can't be done in a docker file.
docker build -t domjudge/judgehost-extended:${VERSION}-build -f Dockerfile  --build-arg VERSION=${VERSION} .
docker rm -f domjudge-judgehost-extended-${VERSION}-build 2>&1 || true
docker run -it --name domjudge-judgehost-extended-${VERSION}-build --privileged domjudge/judgehost-extended:${VERSION}-build /install_languages.sh
docker commit -c "CMD [\"/scripts/start.sh\"]" domjudge-judgehost-extended-${VERSION}-build domjudge/judgehost-extended:${VERSION}
docker rm domjudge-judgehost-extended-${VERSION}-build 2>&1 || true
echo "Succesfull created image domjudge/judgehost-extended:${VERSION}"
exit 0
