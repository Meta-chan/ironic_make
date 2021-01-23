@REM The following file is part of Ironic Make project or was created with it's help
@REM To know more about the project visit github.com/Meta-chan/ironic_make

@REM ironic_base_build.bat
@echo off
setlocal
set VERSION=0
set DIRECTORY=%CD%
set ARGUMENTS=%*

if exist ironic_make.exe (
	for /f "delims=" %%i in ('ironic_make.exe version') do set EXE_VERSION=%%i
	if "%VERSION%"=="%EXE_VERSION%" (
		endlocal
		ironic_make.exe %*
		exit /b %ERRORLEVEL%
	)
)

for /f %%d in ('wmic logicaldisk get name ^| find ":"') do (
	call :try_vs "%%d\Program Files"
	if not errorlevel 1 exit /b 0
	call :try_vs "%%d\Program Files (x86)"
	if not errorlevel 1 exit /b 0
	call :try_gcc "%%d\Program Files"
	if not errorlevel 1 exit /b 0
	call :try_gcc "%%d\Program Files (x86)"
	if not errorlevel 1 exit /b 0
	call :try_gcc "%%d\Program Files\CodeBlocks"
	call :try_gcc "%%d\Program Files (x86)\CodeBlocks"
)

:try_vs
	if exist %1\"Microsoft Visual Studio" (
		cd /d %1\"Microsoft Visual Studio"
		for /f "delims=" %%v in ('dir /b /s /a:-d "vsdevcmd.bat"') do (
			cd /d "%DIRECTORY%"
			call "%%v"
			call :source
			cl ironic_make.c /OUT ironic_make.exe
			if not errorlevel 1 (
				del ironic_make.c
				del ironic_make.obj
				endlocal
				ironic_make.exe %ARGUMENTS%
				exit /b 0
			)
			del ironic_make.c
			del ironic_make.obj
		)
	)
	exit /b 1

:try_gcc
	cd /d %1
	for /f "delims=" %%u in ('dir /b /a:d "*mingw*"') do (
		call :try_gcc2 %%1\"%%u"
		if not errorlevel 1 exit /b 0
	)
	exit /b 1

:try_gcc2
	cd /d %1
	for /f "delims=" %%v in ('dir /b /s /a:d "bin"') do (
		call :try_gcc3 %%v
		if not errorlevel 1 exit /b 0
		exit /b 1
	)
	exit /b 1

:try_gcc3
	cd /d "%DIRECTORY%"
	set PATH=%*;%PATH%
	call :source
	gcc ironic_make.c -o ironic_make.exe
	if not errorlevel 1 (
		del ironic_make.c
		endlocal
		ironic_make.exe %ARGUMENTS%
		exit /b 0
	)
	del ironic_make.c
	exit /b 1

:help
	echo This script will help you to enter Visual Studio comamnd prompt and compile the program under Windows
	echo Possible arguments are:
	echo 	x86		- to compile with x86 32-bit architecture
	echo 	amd64	- to compile with x86 64-bit architecture
	echo 	gcc		- to compile with gcc/g++ compiler
	echo	vs		- to compile with Visual Studio compiler
	echo 	Everything else to ptint this help message
	exit /b 0

:source
	echo #include ^<stdio.h^>							> ironic_make.c
	echo int main() { printf("Hello\n"); return 0; }	>>ironic_make.c
	exit /b 0
	
:makefile
example.exe : example.cpp
	compile example.cpp --output example.exe

all : example.exe