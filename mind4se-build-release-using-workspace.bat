@echo off

setlocal enableextensions

rem *******************************************************************************
rem Need installed and in the path:
rem - mingw (gcc)
rem - maven
rem *******************************************************************************

@echo.===============================================================================
@echo.== MIND4SE Release script: RELEASE BUILD ONLY
@echo.===============================================================================
@echo.
@echo.*******************************************************************************
@echo.[STEP 1] Checking parameter
@echo.

if "%1"=="" echo [ERROR] An existing workspace folder is a mandatory parameter. Exiting. & exit /b 1
set release_folder=%1

@echo.
@echo.*******************************************************************************
@echo.[STEP 2] Checking environment
@echo.

where /q mvn || echo.[ERROR] MAVEN not found in the path. MAVEN is needed to build the release. Exiting. && exit /b 1
@echo.	[INFO] MAVEN found
where /q gcc || echo.[ERROR] GCC not found in the path. GCC is needed to build the release. Exiting. && exit /b 1
@echo.	[INFO] GCC found

@echo.
@echo.*******************************************************************************
@echo.[STEP 3] Build the MIND4SE release into workspace "%release_folder%"
@echo.

pushd %release_folder%

rem Cleanup maven local repository
rem rmdir /Q /S "%USERPROFILE%/.m2/repository"

rem Install mind-compiler pom into maven local repository (all mind4se plug-ins pom depend on this one, needed before building)
@echo mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler
call mvn -U clean install -f ./mind-compiler/pom.xml --projects org.ow2.mind:mind-compiler

rem Build the mind4se release
@echo mvn -U clean install
call mvn -U clean install

popd

endlocal
@echo on
pause