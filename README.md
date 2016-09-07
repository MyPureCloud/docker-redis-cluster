# docker-redis-cluster

Hub: https://hub.docker.com/r/druotic/redis-cluster/

##### Quick Note

This is a fork of Grokzen's [docker-redis-cluster](https://github.com/Grokzen/docker-redis-cluster) which attempts
to strip down some unneeded config and other improvements that make it more useful for a test setup.

There are a few key differences between this docker config and Grokzen's, namely:
  * Removed extra 2 standalone redis instances (ports 7006, 7007) 
  * Advertise IP address to work with both host and bridge networking
  * Allow redis version to be passed in as build arg

# Introduction

Docker image with redis built and installed from source.

The main usage for this container is to test redis cluster code.

The cluster is 6 redis instances running with 3 master & 3 slaves, one slave for each master. They run on ports 7000 to 7005.

The image will build the tag `3.2.3` from the redis git repo unless specified otherwise.

The compose file uses v2 formatting for build arg support, so Compose 1.6.0+
and Docker Engine 1.10.0+ is required.


# Available tags

The following tags with pre-built images is available on `docker-hub`. They are based on the tags in this repo.

  * Latest  (Is the highest tag that currently exists in the redis repo [3.2.3 currently])
  * 3.2.3 (Currently the same as 'Latest')

# Pull

`docker pull druotic/redis-cluster`

# Build (optional)

To build the image, `docker-compose -f compose.yml build`. By default, this will use redis 3.2.3 and will not tag the resulting image.

To specify an alternate redis version (and with optional tagging):

```
docker build --build-arg redis_version=3.2.2 -t <user>/redis-cluster:3.2.2 .
```

# Run

You have a few options for running the image depending on your configuration, but
some quick notes first:

  * The advertised IP referenced below should only be required if working with
  a NAT'd environment like docker-machine. This shouldn't be required on
  linux machines. So, for docker-machine, this would be the IP of the VM and
  can be obtained via `docker-machine ip <name_of_vm>`
  * If host networking is used, REDIS_CLUSTER_ADVERTISED_IP should also be set.
  Otherwise, some private/non-host-routable IP will be bound (bad).
  * After this [redis issue](https://github.com/antirez/redis/issues/2527) is resolved,
  host networking can be removed.

If NAT is involved (docker-machine, etc), use host networking. For example,

`docker run -it -e REDIS_CLUSTER_ADVERTISED_IP=<IP> --net=host druotic/redis-cluster`

(If you built the image yourself, replace user and/or add `:<version>` tag)


If no NAT is involved (native/linux platform),

`docker run -it druotic/redis-cluster`


### Run with Compose

If NAT is involved (docker-machine, etc), use host networking. For example,

`REDIS_CLUSTER_ADVERTISED_IP=<IP> REDIS_CLUSTER_DOCKER_NET_MODE=host docker-compose -f compose.yml up`


If no NAT is involved (native/linux platform),

`docker-compose -f compose.yml up`

Warnings about environment variables not being set can be ignored.

# Connecting to Cluster

```
redis-cli -c -h <host> -p 7000
```

If NAT is involved, host will likely be the ip of the virtual machine if using
something like docker-machine. On linux, this will be the private IP address
of the container which can be obtained from

`docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container name or ID>`

Until announce ip/port is supported by redis, the private IP (or VM ip for host networking) 
and ports 7000-7005 will have to be used when connecting. Otherwise, the provided (binded) ip/port
will not be routable and the initial connect will succeed but node redirects will fail.


# Known Issues

If you get a error when rebuilding the image that docker can't do dns lookup on `archive.ubuntu.com` then you need to modify docker to use google IPv4 DNS lookups. Read the following link http://dannytsang.co.uk/docker-on-digitalocean-cannot-resolve-hostnames/ and uncomment the line in `/etc/default/docker` and restart your docker daemon and it should be fixed.
