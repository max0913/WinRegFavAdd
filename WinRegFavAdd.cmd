@echo off
setlocal enabledelayedexpansion

:: Path to the data file
set "DATA_FILE=WinRegFavAdd-data.md"
set "LOG_FILE=WinRegFavAdd-log.txt"

:: Check if the data file exists
if not exist "%DATA_FILE%" (
    echo Data file not found: %DATA_FILE%
    exit /b 1
)

:: Process each line in the data file
for /f "tokens=2 delims=|" %%a in ('type "%DATA_FILE%" ^| findstr /r "^[^#]"') do (
    set "PATH=%%a"
    set "PATH=!PATH:~1,-1!"
    call :AddRegistryFavorite "!PATH!"
)

:: End of main script
exit /b 0

:AddRegistryFavorite
set "REG_PATH=%~1"
echo Adding to favorites: %REG_PATH%

:: Check if path exists
reg query "%REG_PATH%" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Path does not exist: %REG_PATH% >> "%LOG_FILE%"
    echo Would you like to skip this path and continue? (Y/N)
    set /p "CHOICE="
    if /i "%CHOICE%" neq "Y" (
        exit /b 1
    )
    goto :eof
)

:: Add to favorites (Note: Actual command to add to favorites would go here)
echo Added to favorites: %REG_PATH% >> "%LOG_FILE%"
goto :eof
