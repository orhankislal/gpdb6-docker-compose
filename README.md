# GPUPGRADE Docker Compose

This is a docker compose repository to build and orchestrate a
multinode cluster for dev testing. This can be useful when there is a
need to have multiple hosts and the single-node gpdemo cluster is
insufficient. The docker compose cluster is ephemeral so the
cluster can be discarded and rebuilt for quick and clean testing. The
OS of choice here is CentOS 7.

## Build the image

We need to build a local docker image that will be used for each
container in the multinode cluster. The image here is specifically
designed to work for GPDB 5/6 compilation and running the cluster.

```
pushd ./build/
docker build -t gpdb6-multinode-cluster/gpdb-image .
popd
```

Note: You only have to build the image once (unless there is an update
to the build directory). The image is stored locally.

## Set environment variables

The `docker-compose.yaml` uses four environment variables:
1. `$GPDB5_SRC` (the path to your GPDB 5X source code)
```
Example:
export GPDB5_SRC=/Users/jyih/workspace/gpdb5
```
2. `$GPDB6_SRC` (the path to your GPDB 6X source code)
3. `$GPUPGRADE_SRC` (the path to your gpupgrade source code)
Note: The all of these paths will be mounted and used for compilation
so it would be good to run `git clean -xfd` in the directories to rid of
anything (e.g. MacOS compiled binaries).

4. `$PWD` (the path to the top-level dir of this repository)
Note: You have to run `docker-compose` in the top-level dir anyways so
`$PWD` should always be correct.

## Run docker compose

This step will create the GPDB hosts (3 containers), build a network
bridge between the 3 containers, and mount shared volumes.

```
# In this repository's top-level dir
docker-compose up -d
```

## Run coordinate-everything.sh script

This step will install the compiled GPDB 5 and 6 onto each host and run
gpinitsystem to create the GPDB 5X cluster. It will also compile gpupgrade and
run gpupgrade initialize.

```
pushd ./scripts/
bash coordinate-everything.sh
popd
```

Afterwards, you'll be able to connect to the coordinator node and
start your testing.

```
docker exec -it gpdb6-docker-compose_cdw_1 /bin/bash
su - gpadmin
```

## Recreate database

During testing gpupgrade, we may end up with a partially upgraded cluster. To
return back to a clean state, run the following command.

```
docker exec -it gpdb6-docker-compose_cdw_1 /gpdb-scripts/create-gpdb-cluster.sh
```

## Stop and delete everything

This step will destroy everything we've created. Run this when you no
longer need the cluster.

```
# In this repository's top-level dir
docker-compose down -v
```
