#!/bin/bash

docker run \
     --volume $PWD/dur:/dur \
     --env ISC_DATA_DIRECTORY=/dur/iris \
     -p 52773:52773 \
     --init -it --rm --name iris \
     store/intersystems/iris-community:2020.1.0.197.0
