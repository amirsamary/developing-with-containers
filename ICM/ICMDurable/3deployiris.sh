#!/bin/sh
#
# This is just a shortcut to trigger the deployment of InterSystems IRIS on the provisioned infrastruture.
#
# You should run this AFTER running ./provision.sh
#
source /ICMDurable/env.sh
source /ICMDurable/utils.sh

icm run -stateDir /ICMDurable/State -options "--cap-add IPC_LOCK"
exit_if_error "Deploying container based IRIS failed."

