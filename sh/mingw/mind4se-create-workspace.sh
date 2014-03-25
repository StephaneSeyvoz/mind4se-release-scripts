#!/bin/sh

#export PATH=/c/ECP_SF/Tools/Python-3.3.3:$PATH:/c/ECP_SF/Tools/Git/bin

# *******************************************************************************
# USAGE: mind4se-create-workspace.sh manifest_branch_name workspace_folder
#
# This script generates a full workspace into provided workspace_folder folder
#
# REQUIREMENTS:
# Need installed and in the path:
# - python 3+
# - git 1.7.2+
# - curl or wget download utility
# *******************************************************************************

# PRIVATE - HTTP PROXY
export proxy_url=pipf.fr.schneider-electric.com:8080
export http_proxy=http://$proxy_url
export https_proxy=https://$proxy_url
# PRIVATE - REPO TOOL
export repo_tool_url=https://raw.github.com/esrlabs/git-repo/master/repo
export repo_tool_dir=repo_tool
# PRIVATE - WORKSPACE
export release_default_workspace=mind4se-release
# PRIVATE - MANIFEST
export mind4se_manifest_url=https://github.com/geoffroyjabouley/mind4se-release-manifest
export mind4se_manifest_default_branch=master
export local_release_manifest_file=src/assemble/resources/manifest.xml
# PRIVATE - TOOLS MINIMAL VERSION
[ $python_minimal_version_required ] || export python_minimal_version_required=3
[ $git_minimal_version_required ] || export git_minimal_version_required=1.7.2

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: CREATE WORKSPACE\n'
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

if [ -z "$2" ]; then
	printf '\t[INFO] No release workspace folder provided. Using default worskpace "%s".\n' $release_default_workspace
	export release_workspace=$release_default_workspace
	printf 'Press any key to continue...\n' && read
else
	export release_workspace=$2
fi

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 2] Checking environment\n'
printf '\n'
printf '[STEP 2.1] Checking Tools availability into path\n'
printf '\n'


if ! which python > /dev/null 2>&1; then
	printf '[ERROR] PYTHON not found in the path. PYTHON is needed to download source code. Exiting.\n'
	exit 1
fi
printf '\t[INFO] PYTHON found\n'

if ! which git > /dev/null 2>&1; then
	printf '[ERROR] GIT not found in the path. GIT is needed to download source code. Exiting.\n'
	exit 1
fi
printf '\t[INFO] GIT found\n'

if which curl > /dev/null 2>&1; then
	export curl_available=1
	printf '\t[INFO] CURL found\n'
fi
if which wget > /dev/null 2>&1; then
	export wget_available=1
	printf '\t[INFO] WGET found\n'
fi

if [ ! $curl_available ] && [ ! $wget_available ]; then
	printf '[ERROR] CURL or WGET not found in the path. Needed to download repo tool. Exiting.\n'
	exit 1
fi

printf '\n'
printf '[STEP 2.2] Checking Tools versions\n'
printf '\n'

python --version > output.tmp 2>&1
export python_version=$(cat output.tmp | sed 's/Python \([0-9\.]*\)/\1/')
rm -f output.tmp
printf '\t[INFO] PYTHON version %s.\n' $python_version
if [ "$python_version" \< "$python_minimal_version_required" ]; then
	printf '[ERROR] PYTHON version %s+ is required. Exiting.\n' $python_minimal_version_required
	exit 1
fi

git --version > output.tmp 2>&1
export git_version=$(cat output.tmp | sed 's/git version \(.*\)/\1/')
rm -f output.tmp
printf '\t[INFO] GIT version %s.\n' $git_version
if [ "$git_version" \< "$git_minimal_version_required" ]; then
	printf '[ERROR] GIT version %s+ is required. Exiting.\n' $git_minimal_version_required
	exit 1
fi

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 3] Repo tool install\n'
printf '\n'
printf '[STEP 3.1] Downloading repo tool\n'
printf '\n'

rm -rf $repo_tool_dir > /dev/null 2>&1
mkdir $repo_tool_dir
export https_proxy=$proxy_url
if [ $curl_available ]; then
	printf '\t[INFO] Downloading repo tool from "%s" into folder "%s/%s" using curl' $repo_tool_url $PWD $repo_tool_dir
	curl -x $proxy_url --silent --output $repo_tool_dir/repo $repo_tool_url
fi
if [ ! $curl_available ] && [ $wget_available ]; then
	printf '\t[INFO] Downloading repo tool from "%s" into folder "%s/%s" using wget' $repo_tool_url $PWD $repo_tool_dir
	wget -e https_proxy=$proxy_url --no-check-certificate $repo_tool_url -O $repo_tool_dir/repo > /dev/null 2>&1
fi
chmod a+x $repo_tool_dir/repo

printf '\n'
printf '[STEP 3.2] Installing repo tool in the path\n'
printf '\n'

export PATH=$PATH:$PWD/$repo_tool_dir

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 4] Downloading the MIND4SE source code using repo tool\n'
printf '\n'
printf '[STEP 4.1] Create the release workspace "%s"\n' $release_workspace
printf '\n'

rm -rf $release_workspace > /dev/null 2>&1
mkdir $release_workspace
pushd $release_workspace > /dev/null 2>&1

printf '\n'
printf '[STEP 4.2] Initialize the workspace using manifest file available at\n'
printf '"%s" (branch %s)\n' $mind4se_manifest_url $mind4se_manifest_branch
printf '\n'

repo init -u $mind4se_manifest_url -b $mind4se_manifest_branch || exit 1

printf '\n'
printf '[STEP 4.3] Synchronize the workspace by downloading source code\n'
printf '\n'

repo sync -c --no-clone-bundle --jobs=4 || exit 1

printf '\n'
printf '[STEP 4.4] Generate release specific manifest file into "%s"\n' $local_release_manifest_file
printf '\n'

repo --no-pager manifest -r -o $local_release_manifest_file || exit 1

popd > /dev/null 2>&1
