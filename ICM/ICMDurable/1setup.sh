#!/bin/sh

source /ICMDurable/utils.sh
source /ICMDurable/base_env.sh

printf "\n\n${RED}WARNING: If you continue, this script will regenerate all your SSH/TLS keys and reset your defaults.json and definition.json files."
printf "\n\n${RESET}Do you want to continue? Type yes if you do: "
read answer

if [ "$answer" != 'yes' ];
then
    printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
    exit 0
fi

rm -f ./.provisionHasBeenRun
rm -f /ICMDurable/env.sh
rm -f ./*.json

rm -f ./.provisionHasBeenRun
rm -rf /ICMDurable/State
mkdir /ICMDurable/State
rm -f /ICMDurable/*.log
rm -rf /ICMDurable/.terraform

#
# Setting up SSH and TLS
# 

export SSH_DIR=/ICMDurable/keys
export TLS_DIR=/ICMDurable/keys
echo "export SSH_DIR=${SSH_DIR}" >> /ICMDurable/env.sh
echo "export TLS_DIR=${TLS_DIR}" >> /ICMDurable/env.sh

rm -rf ${SSH_DIR}
rm -rf ${TLS_DIR}

printf "\n\n${GREEN}Generating SSH keys on $SSH_DIR:\n${RESET}"
/ICM/bin/keygenSSH.sh $SSH_DIR

printf "\n\n${GREEN}Generating TLS keys on $TLS_DIR:\n${RESET}"
/ICM/bin/keygenTLS.sh $TLS_DIR

#
# Setting up LABEL for our machines
#

printf "\n\n${GREEN}Please enter with the label for your ICM machines (ex: asamary): ${RESET}"
read ICM_LABEL
exit_if_empty $ICM_LABEL

echo "export ICM_LABEL=$ICM_LABEL" >> /ICMDurable/env.sh
echo "export ICM_TAG=$ICM_TAG" >> /ICMDurable/env.sh

printf "\n\n${GREEN}Do you want IRIS with Mirroring (answer yes or no)?: ${RESET}"
read irisWithMirroringAnswer
exit_if_empty $irisWithMirroringAnswer

if [ "$irisWithMirroringAnswer" == "yes" ];
then
    DM_COUNT=2
    ZONE="us-east-1a,us-east-1b"
    MIRROR="true"
else
    DM_COUNT=1
    ZONE="us-east-1a"
    MIRROR="false"
fi

printf "\n\n${YELLOW}Please enter with your docker credentials so we can pull the images.${RESET}\n"
printf "\n\n${GREEN}Docker Hub username?: ${RESET}"
read DOCKER_USERNAME
exit_if_empty $DOCKER_USERNAME

printf "\n\n${GREEN}Docker Hub password?: ${RESET}"
read -s DOCKER_PASSWORD
exit_if_empty $DOCKER_PASSWORD

#
# Making changes to the template accordingly to user choices
#

cp ./Templates/AWS/defaults.json .
cp ./Templates/AWS/merge.cpf .

sed -E -i  "s;<Label>;$ICM_LABEL;g" ./defaults.json
sed -E -i  "s;<Mirror>;$MIRROR;g" ./defaults.json
sed -E -i  "s;<Zone>;$ZONE;g" ./defaults.json
sed -E -i  "s;<DockerUsername>;$DOCKER_USERNAME;g" ./defaults.json
sed -E -i  "s;<DockerPassword>;$DOCKER_PASSWORD;g" ./defaults.json
sed -E -i  "s;<IRISDockerImage>;$APP_DOCKER_IMAGE;g" ./defaults.json

#
# Creating definitions.json file
#
    echo "
    [
        {
        \"Role\": \"DM\",
        \"Count\": \"${DM_COUNT}\",
        \"LicenseKey\": \"iris.key\"
        }
    ]" >> ./definitions.json

rm -f ./defaults.json.bak

#
# Reminding user of the requirement for AWS credential files
#
if [ ! -f ./aws.credentials ];
then
    printf "\n\n${YELLOW}Put your AWS credentials on file aws.credentials${RESET}\n\n"

    echo "[default]" >> ./aws.credentials
    echo "aws_access_key_id = <your aws access key>" >> ./aws.credentials
    echo "aws_secret_access_key = <your aws secret access key>" >> ./aws.credentials
    echo "aws_session_token = <your aws session token>" >> ./aws.credentials
fi

printf "\n\n${YELLOW}You can run ./2provision.sh to provision the infrastructure on AWS now.\n\n${RESET}"