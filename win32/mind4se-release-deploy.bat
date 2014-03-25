@echo off

setlocal enableextensions

rem set PATH=C:/ECP_SF/Tools/Python-3.3.3;%PATH%;C:/ECP_SF/Tools/Git/cmd

rem *******************************************************************************
rem USAGE: mind4se-release-deploy.bat release_workspace
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem - maven
rem - a valid settings.xml file with teamforge credentials
rem *******************************************************************************

echo.===============================================================================
echo.== MIND4SE Release script: DEPLOY
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

echo.
echo.*******************************************************************************
echo.[STEP 3] Deploying MIND4SE release into teamforge
echo.

pushd %release_workspace%

echo.mvn deploy -rf com.se.mind:min4dse-compiler -Dteamforge
call mvn deploy -rf com.se.mind:min4dse-compiler -Dteamforge || exit /b 1

popd

endlocal
@echo on
