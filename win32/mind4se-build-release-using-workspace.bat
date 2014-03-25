@echo off

setlocal enableextensions

rem *******************************************************************************
rem USAGE: mind4se-build-release-using-workspace.bat release_workspace
rem
rem This script will generate the MIND4SE release with maven using the provided workspace
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem - mingw (gcc)
rem - maven
rem *******************************************************************************

echo.
echo.===============================================================================
echo.== MIND4SE Release script: BUILD RELEASE
echo.===============================================================================
echo.
echo.*******************************************************************************
echo.[STEP 1] Checking parameter
echo.

if "%1"=="" echo [ERROR] An existing workspace folder is a mandatory parameter. Exiting. & exit /b 1
set release_workspace=%1

echo.
echo.*******************************************************************************
echo.[STEP 2] Checking environment
echo.

where /q mvn || echo.[ERROR] MAVEN not found in the path. MAVEN is needed to build the release. Exiting. && exit /b 1
echo.	[INFO] MAVEN found
where /q gcc || echo.[ERROR] GCC not found in the path. GCC is needed to build the release. Exiting. && exit /b 1
echo.	[INFO] GCC found

echo.
echo.*******************************************************************************
echo.[STEP 3] Build the MIND4SE release into workspace "%release_workspace%"
echo.

pushd %release_workspace%

rem Cleanup maven local repository
rem rmdir /Q /S "%USERPROFILE%/.m2/repository"

rem Install mind-compiler pom into maven local repository (all mind4se plug-ins pom depend on this one, needed before building)
echo.mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler
call mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler || exit /b 1

rem Build the mind4se release
echo.mvn -U clean install
call mvn -U clean install || exit /b 1

popd

endlocal
@echo on