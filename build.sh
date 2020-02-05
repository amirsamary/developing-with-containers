#!/bin/bash
VERSION=`cat ./VERSION`
DOCKER_TAG="version-${VERSION}"
DOCKER_REPOSITORY=amirsamary/developing-with-containers

docker build -t ${DOCKER_REPOSITORY}:irisdb-${DOCKER_TAG} ./image-iris
