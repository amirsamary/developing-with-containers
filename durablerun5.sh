#!/bin/bash
VERSION=`cat ./VERSION`
DOCKER_TAG="version-${VERSION}"
DOCKER_REPOSITORY=amirsamary/developing-with-containers

#echo sys123 >> ./dur/password.txt
docker run \
     --volume $PWD/dur:/dur \
     --env ISC_DATA_DIRECTORY=/dur/iris \
     --env ISC_CPF_MERGE_FILE=/dur/merge.cpf \
     -p 52773:52773 \
     --init -it --rm --name iris \
     ${DOCKER_REPOSITORY}:irisdb-${DOCKER_TAG} \
     -p /dur/password.txt

