rem Need installed and in path:
rem - python 3+
rem - mingw
rem - git 1.7.2+
rem - maven 2+
rem - repo tool (see https://github.com/esrlabs/git-repo#setup-steps-for-microsoft-windows) for installation

rem set PATH=C:/ECP_SF/Tools/Python-3.3.3;%PATH%;C:/ECP_SF/Tools/Git/bin;C:/MIND4SE/Workspace/repo/repo_tool

rem Clone all git repositories listed into the manifest
call repo init -u https://github.com/geoffroyjabouley/mind4se-release-manifest
call repo sync

rem Cleanup maven local repository
call rm -rf %USERPROFILE%/.m2/repository

rem Install mind-compiler pom into maven lcoal repository (all mind4se plug-ins pom depend on this one, needed before building) 
call mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler

rem Build the mind4se release
mvn -U clean install -f ./mind4se-compiler/pom.xml