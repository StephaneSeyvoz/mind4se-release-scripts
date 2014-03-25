#!/bin/sh

#export PATH=/c/ECP_SF/Tools/Python-3.3.3:$PATH:/c/ECP_SF/Tools/Git/bin

# *******************************************************************************
# USAGE: mind4se-build-release-using-workspace.sh release_workspace
#
# This script will generate the MIND4SE release with maven using the provided workspace
#
# REQUIREMENTS:
# Need installed and in the path:
# - mingw (gcc)
# - maven
# *******************************************************************************

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: BUILD RELEASE\n'
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

if ! which gcc > /dev/null 2>&1; then
	printf '[ERROR] GCC not found in the path. GCC is needed to build the release. Exiting.\n'
	exit 1
fi
printf '\t[INFO] GCC found\n'

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 3] Build the MIND4SE release into workspace "%s"\n' $release_workspace
printf '\n'

pushd $release_workspace > /dev/null 2>&1

# Cleanup maven local repository
# rm -rf "~/.m2/repository"

# Install mind-compiler pom into maven local repository (all mind4se plug-ins pom depend on this one, needed before building)
printf 'mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler\n'
mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler || exit 1

# Build the mind4se release
printf 'mvn -U clean install\n'
mvn -U clean install || exit 1

popd > /dev/null 2>&1
