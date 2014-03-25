@echo off

setlocal enableextensions

rem set PATH=C:/ECP_SF/Tools/Python-3.3.3;%PATH%;C:/ECP_SF/Tools/Git/bin

rem *******************************************************************************
rem USAGE: mind4se-release-full.bat manifest_branch_name
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem - python 3+
rem - git 1.7.2+
rem - curl or wget download utility
rem - mingw (gcc)
rem - maven
rem *******************************************************************************

rem PRIVATE - WORKSPACE
set release_workspace=mind4se-release
rem PRIVATE - MANIFEST
set mind4se_manifest_default_branch=master

echo.===============================================================================
echo.== MIND4SE Release script: FULL
echo.===============================================================================
echo.
echo.*******************************************************************************
echo.Checking parameter
echo.

if "%1" == "" (
	echo. 	[INFO] No manifest branch name specified. Using default branch "%mind4se_manifest_default_branch%". & set mind4se_manifest_branch=%mind4se_manifest_default_branch%
	pause
) else (
	set mind4se_manifest_branch=%1
)

cmd /c mind4se-create-workspace-only.bat %mind4se_manifest_branch% %release_workspace% || exit /b 1

cmd /c mind4se-build-release-using-workspace.bat %release_workspace% || exit /b 1

endlocal
@echo on
