@REM The following file is part of Ironic Make project or was created with it's help
@REM To know more about the project visit github.com/Meta-chan/example
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
	for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		call :try_disk %%d:
		if not errorlevel 1 (
			echo Compilation success
			call :pause
			exit /b 0
		)
	)
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
	call "%*" %IMAKE_OPTIONS% && cl example.c /link /OUT:example.exe
	if not errorlevel 1 (
		del example.obj 2>nul
		exit /b 0
	)
	del example.obj 2>nul
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
	gcc %IMAKE_OPTIONS% example.c -o example.exe
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
	echo Visit github.com/Meta-chan/example to know more about the project
	exit /b 0
:pause
	for /f "delims=" %%r in ('echo %cmdcmdline% ^| find "\compile.bat"') do pause
	exit /b 0