@echo off
setlocal enableextensions

rem set PATH=C:/ECP_SF/Tools/Python-3.3.3;%PATH%;C:/ECP_SF/Tools/Git/cmd

rem *******************************************************************************
rem USAGE: mind4se-create-workspace.bat manifest_branch_name workspace_folder
rem
rem This script generates a full workspace into provided workspace_folder folder
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem - python 3+
rem - git 1.7.2+
rem - curl or wget download utility
rem *******************************************************************************

rem PRIVATE - HTTP PROXY
set proxy_url=pipf.fr.schneider-electric.com:8080
set http_proxy=http://%proxy_url%
set https_proxy=https://%proxy_url%
rem PRIVATE - REPO TOOL
set repo_tool_url=https://raw.github.com/esrlabs/git-repo/master/repo
set repo_tool_dir=repo_tool
rem PRIVATE - WORKSPACE
set release_default_workspace=mind4se-release
rem PRIVATE - MANIFEST
set mind4se_manifest_url=https://github.com/geoffroyjabouley/mind4se-release-manifest
set mind4se_manifest_default_branch=master
set local_release_manifest_file=src/assemble/resources/manifest.xml
rem PRIVATE - TOOLS MINIMAL VERSION
set python_minimal_version_required=3
set git_minimal_version_required=1.7.2

echo.
echo.===============================================================================
echo.== MIND4SE Release script: CREATE WORKSPACE
echo.===============================================================================
echo.
echo.*******************************************************************************
echo.[STEP 1] Checking parameter
echo.

if "%1" == "" (
	echo. 	[INFO] No manifest branch name specified. Using default branch "%mind4se_manifest_default_branch%". & set mind4se_manifest_branch=%mind4se_manifest_default_branch%
	pause
) else (
	set mind4se_manifest_branch=%1
)

if "%2" == "" (
	echo. 	[INFO] No release workspace folder provided. Using default worskpace "%release_default_workspace%". & set release_workspace=%release_default_workspace%
	pause
) else (
	set release_workspace=%2
)

echo.
echo.*******************************************************************************
echo.[STEP 2] Checking environment
echo.
echo.[STEP 2.1] Checking Tools availability into path
echo.

where /q python || echo.[ERROR] PYTHON not found in the path. PYTHON is needed to download source code. Exiting. && exit /b 1
echo.	[INFO] PYTHON found
where /q git || echo.[ERROR] GIT not found in the path. GIT is needed to download source code. Exiting. && exit /b 1
echo.	[INFO] GIT found

where /q curl && set curl_available=1 && echo.	[INFO] CURL found
where /q wget && set wget_available=1 && echo.	[INFO] WGET found
if not defined curl_available if not defined wget_available echo.[ERROR] CURL or WGET not found in the path. Needed to download repo tool. Exiting. & exit /b 1

echo.
echo.[STEP 2.2] Checking Tools versions
echo.

python --version > output.tmp 2>&1
set /p python_version= < output.tmp
del output.tmp
echo.	[INFO] PYTHON version: %python_version:~7%
if %python_version:~7% lss %python_minimal_version_required% echo.[ERROR] PYTHON version %python_minimal_version_required%+ is required. Exiting. & exit /b 1

git --version > output.tmp 2>&1
set /p git_version= < output.tmp
del output.tmp
echo.	[INFO] GIT version: %git_version:~12%
if %git_version:~12% lss %git_minimal_version_required% echo.[ERROR] GIT version %git_minimal_version_required%+ is required. Exiting. & exit /b 1

echo.
echo.*******************************************************************************
echo.[STEP 3] Repo tool install
echo.
echo.[STEP 3.1] Downloading repo tool
echo.

rmdir /S /Q %repo_tool_dir% > NUL 2>&1
mkdir %repo_tool_dir%
if defined curl_available (
	echo.	[INFO] Downloading repo tool from "%repo_tool_url%" into folder "%repo_tool_dir%" using curl
	curl -x %proxy_url% --silent --output %repo_tool_dir%/repo %repo_tool_url%
	curl -x %proxy_url% --silent --output %repo_tool_dir%/repo.cmd %repo_tool_url%.cmd
)
if not defined curl_available if defined wget_available (
	echo.	[INFO] Downloading repo tool from "%repo_tool_url%" into folder "%repo_tool_dir%" using wget
	wget -e https_proxy=%proxy_url% --no-check-certificate %repo_tool_url% -O %repo_tool_dir%/repo > NUL 2>&1
	wget -e https_proxy=%proxy_url% --no-check-certificate %repo_tool_url%.cmd -O %repo_tool_dir%/repo.cmd > NUL 2>&1
)

echo.
echo.[STEP 3.2] Installing repo tool in the path
echo.

set PATH=%CD:\=/%/%repo_tool_dir%;%PATH:\=/%

echo.
echo.*******************************************************************************
echo.[STEP 4] Downloading the MIND4SE source code using repo tool
echo.
echo.[STEP 4.1] Create the release workspace "%release_workspace%"
echo.

rem rmdir /Q /S %release_workspace% > NUL 2>&1
mkdir %release_workspace%
pushd %release_workspace%

echo.
echo.[STEP 4.2] Initialize the workspace using manifest file available at 
echo. "%mind4se_manifest_url%" (branch %mind4se_manifest_branch%)
echo.

call repo init -u %mind4se_manifest_url% -b %mind4se_manifest_branch% || exit /b 1

echo.
echo.[STEP 4.3] Synchronize the workspace by downloading source code
echo.

call repo sync -c --no-clone-bundle --jobs=4 || exit /b 1

echo.
echo.[STEP 4.4] Generate release specific manifest file into "%local_release_manifest_file%"
echo.

call repo --no-pager manifest -r -o %local_release_manifest_file% || exit /b 1

popd

endlocal
@echo on
