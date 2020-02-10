#!/bin/bash

#echo sys123 >> ./dur/password.txt
docker run \
     --volume $PWD/dur:/dur \
     --env ISC_DATA_DIRECTORY=/dur/iris \
     --env ISC_CPF_MERGE_FILE=/dur/merge.cpf \
     -p 52773:52773 \
     --init -it --rm --name iris \
     store/intersystems/iris-community:2020.1.0.197.0 \
     -p /dur/password.txt

