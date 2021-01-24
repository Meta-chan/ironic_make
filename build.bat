@REM The following file is part of Ironic Make project or was created with it's help
@REM To know more about the project visit github.com/Meta-chan/ironic_make
@REM BATCH
@echo off
setlocal
set IMAKE_DIRECTORY=%CD%
set IMAKE_PATH=%PATH%
set IMAKE_VERSION=0
:start
	if "%1"=="" goto :main
	if "%1"=="vs" goto :compiler
	if "%1"=="gcc" goto :compiler
	if "%1"=="x86" goto :architecture
	if "%1"=="amd64" goto :architecture
	call :help
	exit /b 1
	:compiler
	if not "%IMAKE_COMPILER%"=="" (
		call :help
		call :pause
		exit /b 1
	)
	set IMAKE_COMPILER=%1
	shift
	goto :start
	:architecture
	if not "%IMAKE_ARCHITECTURE%"=="" (
		call :help
		call :pause
		exit /b 1
	)
	set IMAKE_ARCHITECTURE=%1
	shift
	goto :start
	:main
	if exist ironic_make.exe (
		for /f "delims=" %%i in ('ironic_make.exe version') do set IMAKE_EXE_VERSION=%%i
		call :version
		if not errorlevel 1 (
			call :ironic_make %IMAKE_COMPILER% %IMAKE_ARCHITECTURE%
			if not errorlevel 1 (
				call :pause
				exit /b 0
			)
			call :pause
			exit /b 1
		)
	)
	call :source
	for /f %%d in ('wmic logicaldisk get name ^| find ":"') do (
		call :try_disk %%d
		if not errorlevel 1 (
			del ironic_make.c 2>nul
			call :ironic_make %IMAKE_COMPILER% %IMAKE_ARCHITECTURE%
			if not errorlevel 1 (
				call :pause
				exit /b 0
			)
			call :pause
			exit /b 1
		)
	)
	del ironic_make.c 2>nul
	echo Can not compile with specified compiler
	call :pause
	exit /b 1
:version
	if "%IMAKE_VERSION%"=="%IMAKE_EXE_VERSION%" exit /b 0
	exit /b 1
:try_disk
	if not "%IMAKE_COMPILER%"=="" (
		if not "%IMAKE_COMPILER%"=="vs" goto :skip_vs
	)
	call :try_vs_installation "%1\Program Files\"
	if not errorlevel 1 exit /b 0
	call :try_vs_installation "%1\Program Files (x86)\"
	if not errorlevel 1 exit /b 0
	:skip_vs
	if not "%IMAKE_COMPILER%"=="" (
		if not "%IMAKE_COMPILER%"=="gcc" goto :skip_gcc
	)
	call :try_gcc_installation "%1\"
	if not errorlevel 1 exit /b 0
	call :try_gcc_installation "%1\Program Files\"
	if not errorlevel 1 exit /b 0
	call :try_gcc_installation "%1\Program Files (x86)\"
	if not errorlevel 1 exit /b 0
	call :try_gcc_installation "%1\Program Files\CodeBlocks\"
	if not errorlevel 1 exit /b 0
	call :try_gcc_installation "%1\Program Files (x86)\CodeBlocks\"
	if not errorlevel 1 exit /b 0
	:skip_gcc
	exit /b 1
:try_vs_installation
	if not exist %1 exit /b 1
	if exist %1"Microsoft Visual Studio" (
		cd /d %1"Microsoft Visual Studio"
		for /f "delims=" %%v in ('dir /b /s /a:-d "vsdevcmd.bat" 2^>nul') do (
			call :try_vs_vsdevcmd %%v
			if not errorlevel 1 exit /b 0
		)
	)
	exit /b 1
:try_vs_vsdevcmd
	cd /d "%IMAKE_DIRECTORY%"
	REM COMPILE
	set PATH=%IMAKE_PATH%
	set IMAKE_OPTIONS=
	if not "%IMAKE_ARCHITECTURE%"=="" set IMAKE_OPTIONS=-arch=%IMAKE_ARCHITECTURE%
	call "%*" %IMAKE_OPTIONS% && cl ironic_make.c /link /OUT:ironic_make.exe
	if not errorlevel 1 (
		del ironic_make.obj 2>nul
		exit /b 0
	)
	del ironic_make.obj 2>nul
	exit /b 1
:try_gcc_installation
	if not exist %1 exit /b 1
	cd /d %1
	for /f "delims=" %%u in ('dir /b /a:d "*mingw*" 2^>nul') do (
		call :try_gcc_directory %%1\%%u
		if not errorlevel 1 exit /b 0
	)
	exit /b 1
:try_gcc_directory
	cd /d "%*"
	for /f "delims=" %%v in ('dir /b /s /a:d "bin" 2^>nul') do (
		call :try_gcc_path %%v
		if not errorlevel 1 exit /b 0
		exit /b 1
	)
	exit /b 1
:try_gcc_path
	cd /d "%IMAKE_DIRECTORY%"
	REM COMPILE
	set PATH=%*;%IMAKE_PATH%
	if "%IMAKE_ARCHITECTURE%"=="" (
		set IMAKE_OPTIONS=
		gcc --version
	)
	if "%IMAKE_ARCHITECTURE%"=="x86" (
		set IMAKE_OPTIONS=-m32
		gcc --version | findstr "i686"
		if errorlevel 1 exit /b 1
	)
	if "%IMAKE_ARCHITECTURE%"=="amd64" (
		set IMAKE_OPTIONS=-m64
		gcc --version | findstr "x86_64"
		if errorlevel 1 exit /b 1
	)
	gcc %IMAKE_OPTIONS% ironic_make.c -o ironic_make.exe
	exit /b %ERRORLEVEL%
:help
	echo This script will help you to compile your program on Windows
	echo Possible arguments are:
	echo    Nothing - to compile with default compiler and architecture
	echo    x86     - to compile with x86 (32-bit) architecture
	echo    amd64   - to compile with amd64 (x86 64-bit) architecture
	echo    gcc     - to compile with GCC (MinGW) compiler
	echo    vs      - to compile with Visual Studio compiler
	echo    Everything else to ptint this help message
	echo Visit github.com/Meta-chan/ironic_make to know more about the project
	exit /b 0
:pause
	for /f "delims=" %%r in ('echo %cmdcmdline% ^| find "\build.bat"') do pause
	exit /b 0
:ironic_make
	set PATH=%IMAKE_PATH%
	set IMAKE_LINE=
	set IMAKE_LINE_NUMBER=
	set IMAKE_VERSION=
	set IMAKE_EXE_VERSION=
	set IMAKE_PATH=
	set IMAKE_ERROR=
	set IMAKE_OPTIONS=
	set IMAKE_COMPILER=
	set IMAKE_ARCHITECTURE=
	set IMAKE_DIRECTORY=
	ironic_make.exe %*
	exit /b %ERRORLEVEL%
:source
	set IMAKE_LINE_NUMBER=0
	for /f "delims=" %%l in ( build.bat ) do (
		set IMAKE_LINE=%%l
		call :line
	)
	exit /b 0
:line
	set /a IMAKE_LINE_NUMBER=%IMAKE_LINE_NUMBER% + 1
	if %IMAKE_LINE_NUMBER% lss 195 set IMAKE_LINE=
	if %IMAKE_LINE_NUMBER% gtr 202 set IMAKE_LINE=
	if defined IMAKE_LINE echo %IMAKE_LINE% >> ironic_make.c
	exit /b 0
REM SOURCE
#include "stdio.h"
#include "string.h"
int main(int argc, char **argv)
{
	if (argc == 2 ^&^& strcmp("version", argv[1]) == 0) printf("0\n");
	else printf("Build system is not yet implemented (%u-bit)\n", sizeof(void*) == 8 ? 64 : 32);
	return 0;
}
REM MAKEFILE
ironic_make.exe : ironic_make.cpp
	compile $(D)
all : ironic_make.exe