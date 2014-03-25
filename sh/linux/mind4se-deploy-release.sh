#!/bin/sh

#export PATH=/c/ECP_SF/Tools/Python-3.3.3:$PATH:/c/ECP_SF/Tools/Git/bin

# *******************************************************************************
# USAGE: mind4se-deploy-release.sh release_workspace
#
# This script will deploy the MIND4SE release previously generated into release_workspace
#
# REQUIREMENTS:
# Need installed and in the path:
# - maven
# - a valid settings.xml file with teamforge credentials
# *******************************************************************************

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: DEPLOY RELEASE\n'
printf '===============================================================================\n'
printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 1] Checking parameter\n'
printf '\n'

if [ -z "$1" ]; then
	printf '[ERROR] An existing workspace folder is a mandatory parameter. Exiting.\n'
	exit 1
fi
export release_workspace=$1

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 2] Checking environment\n'
printf '\n'

if ! which mvn > /dev/null 2>&1; then
	printf '[ERROR] MAVEN not found in the path. MAVEN is needed to build the release. Exiting.\n'
	exit 1
fi
printf '\t[INFO] MAVEN found\n'

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 3] Deploying MIND4SE release into teamforge\n'
printf '\n'

pushd $release_workspace > /dev/null 2>&1

printf 'mvn collabnet:deploy-to-releases --projects com.se.mind:min4dse-compiler -Dteamforge\n'
mvn collabnet:deploy-to-releases --projects com.se.mind:min4dse-compiler -Dteamforge || exit 1

popd > /dev/null 2>&1
