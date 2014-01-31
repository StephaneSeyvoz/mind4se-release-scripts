#!/bin/sh

# Need installed and in path:
# - python 3+
# - git 1.7.2+
# - maven 2+

# Download and install repo tool into ~/bin/repo
if [ ! -d ~/bin/repo ]; then
	mkdir bin
	curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod a+x ~/bin/repo
fi

mkdir mind4se-release && cd mind4se-release

# Clone all git repositories listed into the manifest
~/bin/repo init -u https://github.com/geoffroyjabouley/mind4se-release-manifest
~/bin/repo sync

# Cleanup maven local repository
rm -rf ~/.m2/repository

# Install mind-compiler pom into maven lcoal repository (all mind4se plug-ins pom depend on this one, needed before building) 
mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler

# Build the mind4se release
mvn -U clean install -f ./mind4se-compiler/pom.xml
