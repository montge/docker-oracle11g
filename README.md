docker-oracle11g
================

Docker + Oracle Linux 6.5 + Oracle Database 11gR2 (Enteprise Edition) setup.
Does not include the DB11g binary.
You need to download that from the official site beforehand.

>This little repo started out as a clone of Guillaume Cusnieux's [dockerisation of Oracle](https://github.com/gcusnieux/docker-oracle11g). However, while I rely on a lot of the work he has done, I've changed the approach to building the container image quite a lot. --hedlund

## Download

Clone this repository to a local directory.  Move the "database" directory to the same folder.

```
$ git clone https://github.com/hedlund/docker-oracle11g
 ```

Then download the database binary (11.2.0) from below.

http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html

* linux.x64_11gR2_database_1of2.zip
* linux.x64_11gR2_database_2of2.zip

Move these two zip-files into the repository clone (don't worry, they're gitignored).


## Image build

As I've changed things around quite a bit compared to the original version, building the thing is quite straightforward:

```
$ cd docker-oracle11g
$ ./build.sh
 ```

This will build an image called `hedlund/oracle11g`. In case you want to build the image with a different tag, simply run:

```
$ docker build -t whatever_you_want .
 ```

>Please note that this takes quite some time (it can take up to 10+ minutes), plus that you *might* run out of disk space in case you're running **Boot2Docker**. In that case you need to [resize your Boot2Docker volume](https://docs.docker.com/articles/b2d_volume_resize/).

## Running a container

Running a container is straightforward:

```
$ docker run -p 1521:1521 hedlund/oracle11g
 ```

This will start the container, map the database port to 1521 so that you can access it, and then simply tail the Oracle listener log to stdout.

I've chosen to not install & run an SSH daemon (which was the case in the original repository), but you can easily add that if you want it.

Accessing the database is easy, simply connect to the container using whatever software you like. *The hostname depends on your local setup - it could be `localhost`, `boot2docker`, `192.168.59.103`, or another IP address:*

	Host: <depends - see above>
	Port: 1521
	SID: oracl
	Username: system
	Password: oracle

You can also start a shell inside the container and access the database locally:

```
$ docker exec -it <container id> bash
$ sqlplus system/oracle@localhost:1521/orcl
 ```

Enjoy!