# Bitcoin Docker

A Dockerfile for building a [`bitcoind`](https://github.com/bitcoin/bitcoin)
docker image.

## Running the Image from Docker Hub

```bash
docker run \
    --detach \
    --name=bitcoin \
    --publish=8332:8332 \
    --publish=8333:8333 \
    --volume=/path/to/config:/etc/bitcoin \
    --volume=/path/to/data:/var/bitcoin \
    cdodd/bitcoin:0.16.0-0
```

You can then view the output of `bitcoind` with `docker logs -f bitcoin`.

The container creates two volumes: one for the bitcoin `datadir` containing the
blockchain and [other data](https://en.bitcoin.it/wiki/Data_directory#Files),
and one containing the `bitcoin.conf` file.

On the first run a basic config file is created in the config volume. You can
modify this and restart the container to change the `bitcoind` config.

## Building the Image

To build from [`master`](https://github.com/bitcoin/bitcoin) just run:

```bash
docker build .
```

To build from a specific git tag, run the following:

```bash
docker build --build-arg BITCOIN_TAG=v0.16.0 .
```
