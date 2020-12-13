@echo off
if "%1"=="" call :help && goto end
if not "%2"=="" call :help && goto end
if "%1"=="x86" call :compile x86 && goto end
if "%1"=="amd64" call :compile amd64 && goto end
call :help
:end
for /f "delims=" %%r in ('echo %cmdcmdline% ^| find "\build.bat"') do pause
exit /b

:compile
	set BUILD_ARCHITECTURE=%1
	if not defined BUILD_VSDEVCMD_PATH (
		if exist ironic_make_cache (
			set /p BUILD_VSDEVCMD_PATH=<ironic_make_cache
			set BUILD_VSDEVCMD_ARCHITECTURE=BUILD_ARCHITECTURE
			call "%%BUILD_VSDEVCMD_PATH%%" -arch=%BUILD_ARCHITECTURE%
		) else (
			call :enter
		)
	)
		
	if defined BUILD_VSDEVCMD_PATH (
		if not "%BUILD_VSDEVCMD_ARCHITECTURE%"=="%BUILD_ARCHITECTURE%" (
			echo Please restart command prompt to compile the program with different architecture
		) else (
			cl main.c
		)
	)
	exit /b

:enter
	SET BUILD_REPOSITORY_DIRECTORY=%CD%
	for /f %%d in ('wmic logicaldisk get name ^| find ":"') do (
		if exist "%%d\Program Files (x86)\Microsoft Visual Studio" (
			cd /d "%%d\Program Files (x86)\Microsoft Visual Studio"
			for /f "delims=" %%v in ('dir /b /s /a:-d "vsdevcmd.bat"') do (
				cd /d "%BUILD_REPOSITORY_DIRECTORY%"
				echo %%v> ironic_make_cache
				set BUILD_VSDEVCMD_PATH=%%v
				set BUILD_VSDEVCMD_ARCHITECTURE=%BUILD_ARCHITECTURE%
				call "%%BUILD_VSDEVCMD_PATH%%" -arch=%%BUILD_ARCHITECTURE%%
				exit /b
			)
		)
	)
	echo "Visual Studio compiler not found. If you are using non-standard location, create file named 'ironic_make_cache' with full path to vsdevcmd.bat"
	exit /b

:help
	echo This script will help you to enter Visual Studio comamnd prompt and compile the program under Windows
	echo Possible arguments are:
	echo 	x86 - to compile with x86 32-bit architecture
	echo 	amd64 - to compile with x86 64-bit architecture
	echo 	Everything else to ptint this help message
	exit /b