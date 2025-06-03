@echo off
setlocal enabledelayedexpansion

:: Define directories
set "DATA_DIR=data-files"
set "LOG_FILE=WinRegFavAdd-log.txt"

:: Check if the data directory exists
if not exist "%DATA_DIR%" (
    echo Data directory not found: %DATA_DIR%
    exit /b 1
)

:: List all data files and allow user to select one
echo Please select a profile to process:
set COUNT=0
for %%f in ("%DATA_DIR%\*.md") do (
    set /a COUNT+=1
    echo !COUNT!. %%~nf
    set "FILE_!COUNT!=%%f"
)

:: Get user selection
set /p "SELECTION=Enter number (1 to %COUNT%): "
set "DATA_FILE=!FILE_%SELECTION%!"

:: Check if user selection is valid
if not defined DATA_FILE (
    echo Invalid selection.
    exit /b 1
)

:: Process each line in the data file
:: Only process table rows starting with a pipe character. Trim the
:: surrounding spaces and backticks from the extracted path.
for /f "tokens=2 delims=|" %%a in ('type "%DATA_FILE%" ^| findstr /r "^|"') do (
    set "PATH=%%a"
    set "PATH=!PATH:~1,-1!"
    if "!PATH:~,1!"=="`" set "PATH=!PATH:~1,-1!"
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
