#!/bin/bash
#
# Because I am an InterSystems emmployee, I can't pull IRIS from the docker store. Only a
# customer can do that. So I pull IRIS from our internal docker registry and push it to
# my private repository on Docker Hub. 
#
# If you are an InterSystems employee, you should have a private repository on Docker Hub 
# for running this demo on ICM
#
# If you are a customer, you will be able to configure IRIS_PRIVATE_REPO with the official
# docker hub InterSystems repository name and you should not need to use putirisondockerhub.sh.
#
# JUST MAKE SURE THE VERSION OF ICM YOU ARE USING IS THE SAME VERSION OF IRIS YOU ARE USING 
# ON YOUR IMAGES!
#

# These two are used on the script putirisondockerhub.sh and also by icm.* scripts
export IRIS_TAG=2020.1.0.197.0
export IRIS_PRIVATE_REPO=amirsamary/irisdemo

# You can change the image of your APP. But it must end with -version-n.n.n
# We will replace this every time you bump the version on this git repo (see bumpversion.sh)
export APP_DOCKER_IMAGE=amirsamary/developing-with-containers:irisdb-version-1.5.0

