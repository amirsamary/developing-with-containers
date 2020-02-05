#!/bin/bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

# Some times, when we stop docker-compose, it will leave the containers running. 
# We are configuring a trap to detect CTRL+C and verify if all containers are removed.
cleanup()
{
    printf "\n\n${PURPLE}CTRL+C detected. Removing containters...${RESET}\n"
    docker-compose stop
    docker-compose rm -f

    printf "\n\n${PURPLE}Cleaning up complete.${RESET}\n"
    trap - INT
}
trap cleanup INT

# Starting a new composition, let's stop the compostion, remove previous containers and start it again
docker-compose stop
docker-compose rm -f
docker-compose up --remove-orphans