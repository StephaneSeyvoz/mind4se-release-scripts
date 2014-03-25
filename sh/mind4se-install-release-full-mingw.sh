#!/bin/sh

# export PATH=/c/ECP_SF/Tools/Python-3.3.3:$PATH:/c/ECP_SF/Tools/Git/bin

# *******************************************************************************
# USAGE: mind4se-install-release-full-mingw.sh manifest_branch_name
#
# This script will create a workspace and then generate a MIND4SE release
#
# REQUIREMENTS:
# Need installed and in the path:
# - python 3+
# - git 1.7.2+
# - curl or wget download utility
# - mingw (gcc)
# - maven
# *******************************************************************************

# PRIVATE - WORKSPACE
export release_workspace=mind4se-release
# PRIVATE - MANIFEST
export mind4se_manifest_default_branch=master

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: INSTALL RELEASE FULL\n'
printf '===============================================================================\n'
printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 1] Checking parameter\n'
printf '\n'

if [ -z "$1" ]; then
	printf '\t[INFO] No manifest branch name specified. Using default branch "%s".\n' $mind4se_manifest_default_branch
	export mind4se_manifest_branch=$mind4se_manifest_default_branch
	printf 'Press any key to continue...\n' && read
else
	export mind4se_manifest_branch=$1
fi

/bin/sh mind4se-create-workspace-mingw.sh $mind4se_manifest_branch $release_workspace || exit 1

/bin/sh mind4se-install-release.sh $release_workspace || exit 1
