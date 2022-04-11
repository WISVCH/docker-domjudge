Docker for DOMjudge
===================

These Dockerfiles allow you to run [DOMjudge](https://www.domjudge.org) inside a
Docker container.

Usage
-----

Use Docker Compose to build the images:

	$ docker-compose -f docker-compose-domserver.yml up
	$ docker-compose -f docker-compose-judgehost.yml up --build

You may want to edit `domserver/apache.conf.in` to enable TLS or tweak the PHP
upload restrictions.

All environment variables can be set in the relevant `*.env` files.

### domserver

The domserver compose file comes bundled with a MariaDB container. If you want
to use this, you only need to specify a password for the mysql root user and for
the domjudge user by setting `MYSQL_ROOT_PASSWORD` to the root password, and
`MYSQL_PASSWORD` to the domjudge user password. You can also use a
standalone MySQL server. In that case, you need to specify the
`MYSQL_HOST` variable. It is also possible to specify a database name and
domjudge user name (both default to `domjudge`) by setting `MYSQL_DATABASE`
and `MYSQL_USER`.

If you use a reverse proxy, you need to set `TRUSTED_PROXIES` to the IP
or host name of your proxy.

You can also specify a timezone by setting the `CONTAINER_TIMEZONE` variable.

### judgehost

As for the judgehost, you need to run the container in privileged mode to use
cgroups. You also need to specify the domserver URL and judgehost user password
by setting `DOMSERVER_HOST`, `DOMSERVER_PASSWORD`. You can set `DOMJUDGE_USER`
as well, but it defaults to `judgehost`. You should also specify a hostname for
this container to identify it in the domserver.

If you want to support more programming languages, you need to edit
`judgehost/languages` to enable/disable languages. If a language you want isn't
listed, feel free to create an issue or submit a pull request!

You also need to specify the following kernel parameters on the container host
for cgroups: `cgroup_enable=memory swapaccount=1`.

Patches
-------

You can customize the DOMjudge source by adding patches to the `patches`
directories.

ICPC Tools
==========

The [ICPC tools](https://icpc.baylor.edu/icpctools/) can be used by domjudge
with some workarounds. After setting up the contest and autojudges, the
following steps can be used to get several tools working.

*Make sure the contest is created and active*

* Create an user for the event feed (e.g. event) with the role `API_READER` and `Source`
* Update the passwords and contest id in `cds.env`
* Start the contest data server

	$ docker-compose -f docker-compose-cds.yml up --build

* Verify everything works by going to
  `https://<host>:8443/contests/<contest-id>` (The first time you visit this
  link, it will retrieve the data.)

### Adding custom slides to the presentation(e.g. sponsors/promo)
Add in the `photos` directory the images as `jpg` or `png` that you want to
make available to the presentations client.  Select the `Photos` presentation
to display the images.

Setting up Presentation server
------------------------------
Download the latest version of Presentation Controller and unzip the file. Run
the following command to connect to the cds

		$ ./presAdmin.sh https://<cds-host> admin <adminPassword>

Setting up the Presentation client
----------------------------------
Download the latest version of Presentation Client and unzip the file. Run the
following command to the connect to the cds.

		$ ./client.sh <clientName> https://<cds-host>/api/contests/<contest-id> presentation <presentation-password>

Setting up the Resolver with custom places
------------------------------------------
Download the latest version of the Resolver and unzip the file. Generate the
standing by running the `awards` script and connect to your cds using the
url `https://<cds-host>/api/contests/<contest-id>` with the `admin` account.

Setup the standings as desired and save the file as `awards.json`.

Now the scoreboard can be resolved with custom places and awards by executing

        $ resolver event-feed.json
