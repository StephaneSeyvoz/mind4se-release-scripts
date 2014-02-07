#!/bin/sh

# Need installed and in path:
# - python 3+
# - git 1.7.2+
# - maven 2+

# Download and install repo tool into ~/bin/repo
if [ ! -f bin/repo ]; then
	mkdir -p bin
	curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo
	chmod a+x bin/repo
	export PATH=$PATH:`pwd bin`
fi

export release_folder=mind4se-release

rm -rf $release_folder
mkdir -p $release_folder && cd $release_folder

# Clone all git repositories listed into the manifest
repo init -u https://github.com/geoffroyjabouley/mind4se-release-manifest
repo sync -c --no-clone-bundle --jobs=4

# Generate manifest.xml file for the release
repo --no-pager manifest -r -o src/assemble/resources/manifest.xml

# Cleanup maven local repository
rm -rf ~/.m2/repository

# Install mind-compiler pom into maven lcoal repository (all mind4se plug-ins pom depend on this one, needed before building) 
mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler

# Build the mind4se release
mvn -U clean install -PCI-profile

cd ..