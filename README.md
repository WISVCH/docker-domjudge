Docker for DOMjudge
===================

These Dockerfiles allow you to run [DOMjudge](https://www.domjudge.org) inside a
Docker container.

Usage
-----

Use Docker Compose to build the images:

	$ docker-compose -f docker-compose-domserver.yml up --build
	$ docker-compose -f docker-compose-judgehost.yml up --build

You may want to edit `domserver/apache.conf.in` to enable TLS or tweak the PHP
upload restrictions.

The domserver compose file comes bundled with a MariaDB container. If you want
to use this, you only need to specify a password for the mysql root user and 
for the domjudge user by setting `DOMJUDGE_DB_ROOT_PASSWORD` and
`MYSQL_ROOT_PASSWORD` to the root password, and `DOMJUDGE_DB_PASSWORD` to the
domjudge user password. You can also use a standalone MySQL server. In that
case, you need to specify the `DOMJUDGE_DB_HOST` variable. It is also possible
to specify a database name and domjudge user name (both default to `domjudge`)
by setting `DOMJUDGE_DB_NAME` and `DOMJUDGE_DB_USER`.

As for the judgehost, you need to run the container in privileged mode to use
cgroups. You also need to specify the domserver URL and judgehost user and
password in `judgehost/restapi.secret`. You should also specify a hostname for
this container to identify it in the domserver. If you want to support more
programming languages, you need to edit `judgehost/Dockerfile` to download the
packages.

Patches
-------

You can customize the DOMjudge source by adding patches to the `patches`
directories.
