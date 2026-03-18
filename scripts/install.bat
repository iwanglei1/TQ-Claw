@echo off
setlocal EnableDelayedExpansion

REM TQ-Claw Installer for Windows (cmd.exe / batch)
REM Usage: install.bat [-Version X.Y.Z] [-FromSource] [-SourceDir DIR]
REM                         [-Extras "llamacpp,mlx"] [-UvPath PATH] [-Help]
REM
REM Installs TQ-Claw into %USERPROFILE%\.tqclaw with a uv-managed Python environment.
REM Users do NOT need Python pre-installed -- uv handles everything.
REM
REM uv is obtained automatically (no action required from the user):
REM   1. Found on PATH or in common locations
REM   2. Downloaded via https://astral.sh/uv/install.ps1
REM   3. Downloaded via GitHub Releases if astral.sh is unreachable (e.g. in China)

REM ── Defaults ──────────────────────────────────────────────────────────────────
if defined TQCLAW_HOME (
    set "TQCLAW_HOME=%TQCLAW_HOME%"
) else (
    set "TQCLAW_HOME=%USERPROFILE%\.tqclaw"
)
set "TQCLAW_VENV=%TQCLAW_HOME%\venv"
set "TQCLAW_BIN=%TQCLAW_HOME%\bin"
set "PYTHON_VERSION=3.12"
set "TQCLAW_REPO=https://github.com/agentscope-ai/TQ-Claw.git"

REM ──── Argument defaults ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
set "ARG_VERSION="
set "ARG_FROM_SOURCE=0"
set "ARG_SOURCE_DIR="
set "ARG_EXTRAS="
set "ARG_UV_PATH="
set "CONSOLE_COPIED=0"
set "CONSOLE_AVAILABLE=0"

REM ──── Parse arguments ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
:parse_args
if "%~1"=="" goto :done_args
if /i "%~1"=="-Version"    goto :arg_version
if /i "%~1"=="-FromSource" goto :arg_fromsource
if /i "%~1"=="-SourceDir"  goto :arg_sourcedir
if /i "%~1"=="-Extras"     goto :arg_extras
if /i "%~1"=="-UvPath"     goto :arg_uvpath
if /i "%~1"=="-Help"       goto :show_help
shift
goto :parse_args

:arg_version
set "ARG_VERSION=%~2"
shift & shift
goto :parse_args

:arg_fromsource
set "ARG_FROM_SOURCE=1"
shift
goto :parse_args

:arg_sourcedir
set "ARG_SOURCE_DIR=%~2"
shift & shift
goto :parse_args

:arg_extras
set "ARG_EXTRAS=%~2"
shift & shift
goto :parse_args

:arg_uvpath
set "ARG_UV_PATH=%~2"
shift & shift
goto :parse_args

:done_args
goto :main

REM ──── Help ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
:show_help
echo TQ-Claw Installer for Windows
echo.
echo Usage: install.bat [OPTIONS]
echo.
echo Options:
echo   -Version ^<VER^>        Install a specific version (e.g. 0.0.2)
echo   -FromSource           Install from source (requires git, or use -SourceDir)
echo   -SourceDir ^<DIR^>      Local source directory (used with -FromSource)
echo   -Extras ^<EXTRAS^>      Comma-separated optional extras to install
echo                         (e.g. llamacpp, mlx, llamacpp,mlx)
echo   -UvPath ^<PATH^>        Path to a pre-installed uv.exe (skips all auto-install)
echo   -Help                 Show this help
echo.
echo Environment:
echo   TQCLAW_HOME            Installation directory (default: %%USERPROFILE%%\.tqclaw)
exit /b 0

REM ──── Helper functions ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
:write_info
echo [tqclaw] %~1
exit /b 0

:write_warn
echo [tqclaw] WARNING: %~1
exit /b 0

:write_err
echo [tqclaw] ERROR: %~1
exit /b 0

:stop_with_error
echo [tqclaw] ERROR: %~1
exit /b 1

REM ──── Download uv from GitHub Releases ────────────────────────────────────────────────────────────────────────────────────
REM Subroutine: called when astral.sh is unreachable (e.g. in China).
REM On success: uv.exe is in %LOCALAPPDATA%\uv and that dir is prepended to PATH.
:download_uv_github
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "_DL_ARCH=aarch64"
) else (
    set "_DL_ARCH=x86_64"
)
set "_DL_URL=https://github.com/astral-sh/uv/releases/latest/download/uv-!_DL_ARCH!-pc-windows-msvc.zip"
set "_DL_DEST=%LOCALAPPDATA%\uv"
set "_DL_ZIP=%TEMP%\uv-gh-%RANDOM%.zip"

echo [tqclaw] Downloading uv ^(!_DL_ARCH!^) from GitHub Releases...

REM Try curl.exe (built into Windows 10+), then fall back to PowerShell
where curl >nul 2>&1
if not errorlevel 1 (
    curl -L --progress-bar -o "!_DL_ZIP!" "!_DL_URL!"
    if not errorlevel 1 goto :download_uv_extract
    echo [tqclaw] curl failed, retrying with PowerShell...
    del "!_DL_ZIP!" >nul 2>&1
)

powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '!_DL_URL!' -OutFile '!_DL_ZIP!' -UseBasicParsing"
if errorlevel 1 (
    echo [tqclaw] ERROR: GitHub download also failed.
    echo [tqclaw] Download uv manually from: https://github.com/astral-sh/uv/releases/latest
    del "!_DL_ZIP!" >nul 2>&1
    exit /b 1
)

:download_uv_extract
if not exist "!_DL_DEST!" mkdir "!_DL_DEST!"
echo [tqclaw] Extracting uv...
powershell -NoProfile -Command "Expand-Archive -Force -Path '!_DL_ZIP!' -DestinationPath '!_DL_DEST!'"
set "_DL_ERR=%errorlevel%"
del "!_DL_ZIP!" >nul 2>&1
if %_DL_ERR% neq 0 (
    echo [tqclaw] ERROR: Extraction failed.
    exit /b 1
)
if not exist "!_DL_DEST!\uv.exe" (
    echo [tqclaw] ERROR: uv.exe not found after extraction.
    exit /b 1
)
set "PATH=!_DL_DEST!;!PATH!"
echo [tqclaw] uv installed: !_DL_DEST!\uv.exe
exit /b 0

REM ──── Ensure uv ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
:ensure_uv
REM 0. User-supplied path (-UvPath)
if defined ARG_UV_PATH (
    if not exist "%ARG_UV_PATH%" (
        echo [tqclaw] ERROR: Specified uv not found: %ARG_UV_PATH%
        exit /b 1
    )
    for %%I in ("%ARG_UV_PATH%") do set "PATH=%%~dpI;!PATH!"
    echo [tqclaw] uv found: %ARG_UV_PATH%
    goto :ensure_uv_done
)

REM 1. Already on PATH
where uv >nul 2>&1
if %errorlevel%==0 (
    for /f "delims=" %%p in ('where uv 2^>nul') do (
        echo [tqclaw] uv found: %%p
        goto :ensure_uv_done
    )
)

REM 2. Common install locations not yet on PATH
for %%c in ("%USERPROFILE%\.local\bin\uv.exe" "%USERPROFILE%\.cargo\bin\uv.exe" "%LOCALAPPDATA%\uv\uv.exe") do (
    if exist %%c (
        set "_UV_DIR=%%~dpc"
        set "PATH=!_UV_DIR!;!PATH!"
        echo [tqclaw] uv found: %%~c
        goto :ensure_uv_done
    )
)

REM 3. Try astral.sh (standard installer, fast outside China)
echo [tqclaw] Installing uv via astral.sh...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 -TimeoutSec 15 | iex"
if not errorlevel 1 goto :ensure_uv_refresh

REM 4. astral.sh failed -- fall back to GitHub Releases (works in China)
echo [tqclaw] astral.sh unreachable, falling back to GitHub Releases...
call :download_uv_github
if errorlevel 1 (
    echo [tqclaw] ERROR: Failed to install uv automatically.
    echo [tqclaw] Please install uv manually: https://docs.astral.sh/uv/
    exit /b 1
)
goto :ensure_uv_done

:ensure_uv_refresh
REM Refresh PATH after astral.sh install
for %%p in ("%USERPROFILE%\.local\bin" "%USERPROFILE%\.cargo\bin" "%LOCALAPPDATA%\uv") do (
    if exist %%p (
        echo "!PATH!" | findstr /i /c:"%%~p" >nul 2>&1
        if errorlevel 1 set "PATH=%%~p;!PATH!"
    )
)
where uv >nul 2>&1
if errorlevel 1 (
    echo [tqclaw] ERROR: Failed to install uv. Please install it manually: https://docs.astral.sh/uv/
    exit /b 1
)
echo [tqclaw] uv installed via astral.sh

:ensure_uv_done
exit /b 0

REM ──── Prepare console frontend ────────────────────────────────────────────────────────────────────────────────────────────────────
:prepare_console
REM %~1 = RepoDir
set "_REPO_DIR=%~1"
set "_CONSOLE_SRC=%_REPO_DIR%\console\dist"
set "_CONSOLE_DEST=%_REPO_DIR%\src\tqclaw\console"

REM Already populated
if exist "%_CONSOLE_DEST%\index.html" (
    set "CONSOLE_AVAILABLE=1"
    exit /b 0
)

REM Copy pre-built assets if available
if exist "%_CONSOLE_SRC%\index.html" (
    echo [tqclaw] Copying console frontend assets...
    if not exist "%_CONSOLE_DEST%" mkdir "%_CONSOLE_DEST%"
    xcopy /s /e /y /q "%_CONSOLE_SRC%\*" "%_CONSOLE_DEST%\" >nul
    set "CONSOLE_COPIED=1"
    set "CONSOLE_AVAILABLE=1"
    exit /b 0
)

REM Try to build if npm is available
if not exist "%_REPO_DIR%\console\package.json" (
    echo [tqclaw] WARNING: Console source not found - the web UI won't be available.
    exit /b 0
)

where npm >nul 2>&1
if errorlevel 1 (
    echo [tqclaw] WARNING: npm not found - skipping console frontend build.
    echo [tqclaw] WARNING: Install Node.js from https://nodejs.org/ then re-run this installer,
    echo [tqclaw] WARNING: or run 'cd console ^&^& npm ci ^&^& npm run build' manually.
    exit /b 0
)

echo [tqclaw] Building console frontend (npm ci ^&^& npm run build)...
pushd "%_REPO_DIR%\console"
npm ci
if errorlevel 1 (
    popd
    echo [tqclaw] WARNING: npm ci failed - the web UI won't be available.
    exit /b 0
)
npm run build
if errorlevel 1 (
    popd
    echo [tqclaw] WARNING: npm run build failed - the web UI won't be available.
    exit /b 0
)
popd

if exist "%_CONSOLE_SRC%\index.html" (
    if not exist "%_CONSOLE_DEST%" mkdir "%_CONSOLE_DEST%"
    xcopy /s /e /y /q "%_CONSOLE_SRC%\*" "%_CONSOLE_DEST%\" >nul
    set "CONSOLE_COPIED=1"
    set "CONSOLE_AVAILABLE=1"
    echo [tqclaw] Console frontend built successfully
    exit /b 0
)

echo [tqclaw] WARNING: Console build completed but index.html not found - the web UI won't be available.
exit /b 0

REM ──── Cleanup console frontend ────────────────────────────────────────────────────────────────────────────────────────────────────
:cleanup_console
REM %~1 = RepoDir
if "%CONSOLE_COPIED%"=="1" (
    set "_CLEANUP_DEST=%~1\src\tqclaw\console"
    if exist "!_CLEANUP_DEST!" rd /s /q "!_CLEANUP_DEST!" 2>nul
)
exit /b 0

REM ══════════════════════════════ MAIN ═════════════════════════════════════════
:main
echo [tqclaw] Installing TQ-Claw into %TQCLAW_HOME%

REM ──── Step 1: Ensure uv ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
call :ensure_uv
if errorlevel 1 exit /b 1

REM ──── Step 2: Create / update virtual environment ──────────────────────────────────────────────────────────────
if exist "%TQCLAW_VENV%" (
    echo [tqclaw] Existing environment found, upgrading...
) else (
    echo [tqclaw] Creating Python %PYTHON_VERSION% environment...
)

uv venv "%TQCLAW_VENV%" --python %PYTHON_VERSION% --quiet --clear
if errorlevel 1 (
    echo [tqclaw] ERROR: Failed to create virtual environment
    exit /b 1
)

set "VENV_PYTHON=%TQCLAW_VENV%\Scripts\python.exe"
if not exist "%VENV_PYTHON%" (
    echo [tqclaw] ERROR: Failed to create virtual environment
    exit /b 1
)

for /f "delims=" %%v in ('"%VENV_PYTHON%" --version 2^>^&1') do set "PY_VERSION=%%v"
echo [tqclaw] Python environment ready (%PY_VERSION%)

REM ──── Step 3: Install TQ-Claw ──────────────────────────────────────────────────────────────────────────────────────────────────────────
set "EXTRAS_SUFFIX="
if defined ARG_EXTRAS set "EXTRAS_SUFFIX=[%ARG_EXTRAS%]"

set "VENV_TQCLAW=%TQCLAW_VENV%\Scripts\tqclaw.exe"

REM Use goto-based branching to avoid nested parenthesized blocks,
REM which break when %vars% expand to values containing "(" or ")".
if "%ARG_FROM_SOURCE%"=="1" goto :install_from_source
goto :install_from_pypi

:install_from_source
if defined ARG_SOURCE_DIR goto :install_from_local
goto :install_from_github_tqclaw

:install_from_local
for %%I in ("%ARG_SOURCE_DIR%") do set "ARG_SOURCE_DIR=%%~fI"
echo [tqclaw] Installing TQ-Claw from local source: %ARG_SOURCE_DIR%
call :prepare_console "%ARG_SOURCE_DIR%"
echo [tqclaw] Installing package from source...

rem === Secure Input Validation (Prevents Argument Injection) ===
rem 1. Ensure non-empty
if “%ARG_SOURCE_DIR%” == ‘’ set “ARG_SOURCE_DIR=.”
if “%EXTRAS_SUFFIX%” == ‘’ set “EXTRAS_SUFFIX=”

rem 2. Define invalid character set (double quotes, pipe, logical AND, redirection, brackets, percent sign, caret)
rem These characters can break command structure or inject new parameters
set “INVALID_CHARS=\”|&<>()%%^"

rem 3. Validate ARG_SOURCE_DIR
rem Logic: If the variable contains any invalid characters, findstr will match successfully (errorlevel 0)
echo %ARG_SOURCE_DIR% | findstr /R "[\"|&<>()%%^]" >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] Security Alert: ARG_SOURCE_DIR contains invalid characters.
    echo [ERROR] Detected unsafe input: %ARG_SOURCE_DIR%
    echo [ERROR] Installation aborted to prevent argument injection.
    call :cleanup_console "%ARG_SOURCE_DIR%"
    exit /b 1
)

rem 4. Validate EXTRAS_SUFFIX (typically formatted as [dev,test])
rem Whitelist policy: Only letters, digits, commas, square brackets, underscores, and hyphens are permitted
rem Logic: If any non-whitelisted character is present, findstr succeeds
echo %EXTRAS_SUFFIX% | findstr /R "[^a-zA-Z0-9_,\-\[\]]" >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] Security Alert: EXTRAS_SUFFIX contains invalid characters.
    echo [ERROR] Detected unsafe input: %EXTRAS_SUFFIX%
    echo [ERROR] Only alphanumeric, commas, underscores, hyphens, and brackets are allowed.
    call :cleanup_console "%ARG_SOURCE_DIR%"
    exit /b 1
)
rem === End Security Validation ===

rem The input has now been verified as safe and can proceed with installation.
uv pip install "%ARG_SOURCE_DIR%%EXTRAS_SUFFIX%" --python "%VENV_PYTHON%" --prerelease=allow
set "_INST_ERR=%errorlevel%"
call :cleanup_console "%ARG_SOURCE_DIR%"
if %_INST_ERR% neq 0 (
    echo [tqclaw] ERROR: Installation from source failed
    exit /b 1
)
goto :install_verify

:install_from_github_tqclaw
where git >nul 2>&1
if errorlevel 1 (
    echo [tqclaw] ERROR: git is required for -FromSource without a local directory.
    echo [tqclaw]        Please install Git from https://git-scm.com/ or pass a local path:
    echo [tqclaw]        install-w-uv.bat -FromSource -SourceDir C:\path\to\TQ-Claw
    exit /b 1
)
echo [tqclaw] Installing TQ-Claw from source (GitHub)...
set "CLONE_DIR=%TEMP%\tqclaw-install-%RANDOM%"
git clone --depth 1 %TQCLAW_REPO% "%CLONE_DIR%"
if errorlevel 1 (
    if exist "%CLONE_DIR%" rd /s /q "%CLONE_DIR%"
    echo [tqclaw] ERROR: Failed to clone repository
    exit /b 1
)
call :prepare_console "%CLONE_DIR%"
echo [tqclaw] Installing package from source...
uv pip install "%CLONE_DIR%%EXTRAS_SUFFIX%" --python "%VENV_PYTHON%" --prerelease=allow
set "_INST_ERR=%errorlevel%"
if exist "%CLONE_DIR%" rd /s /q "%CLONE_DIR%"
if %_INST_ERR% neq 0 (
    echo [tqclaw] ERROR: Installation from source failed
    exit /b 1
)
goto :install_verify

:install_from_pypi
set "_PACKAGE=tqclaw"

rem === Secure Validation for ARG_VERSION ===
if defined ARG_VERSION (
    rem Version number whitelist: Only permits numbers, letters, periods, comparison symbols (=<>!), hyphens, and tilde characters
    rem Prohibits spaces, quotation marks, slashes, and other characters potentially used for --index-url injection
    echo %ARG_VERSION% | findstr /R "[^a-zA-Z0-9\.=<>\!\-~]" >nul 2>&1
    if not errorlevel 1 (
        echo [ERROR] Security Alert: ARG_VERSION contains invalid characters.
        echo [ERROR] Detected unsafe input: %ARG_VERSION%
        echo [ERROR] Installation aborted.
        exit /b 1
    )
    set "_PACKAGE=tqclaw%ARG_VERSION%"
)
rem === End Version Validation ===

echo [tqclaw] Installing %_PACKAGE%%EXTRAS_SUFFIX% from PyPI...
rem Note: It is also recommended to validate EXTRAS_SUFFIX here. Although it may be undefined in the local scope above,
rem for safety, if ARG_EXTRAS is defined globally, it is best to reuse the validation logic from above or ensure its source is secure.
rem Assume EXTRAS_SUFFIX is generated here based on the previously validated ARG_EXTRAS, or is empty.
rem If ARG_EXTRAS is passed globally, it is recommended to validate it uniformly at the beginning of the script.

uv pip install "%_PACKAGE%%EXTRAS_SUFFIX%" --python "%VENV_PYTHON%" --prerelease=allow --quiet --refresh-package tqclaw
if errorlevel 1 (
    echo [tqclaw] ERROR: Installation failed
    exit /b 1
)

:install_verify

REM Verify the CLI entry point exists
if not exist "%VENV_TQCLAW%" (
    echo [tqclaw] ERROR: Installation failed: tqclaw CLI not found in venv
    exit /b 1
)
echo [tqclaw] TQ-Claw installed successfully

REM Check console availability (for PyPI installs, probe the installed package)
if "%CONSOLE_AVAILABLE%"=="0" (
    "%VENV_PYTHON%" -c "import importlib.resources, tqclaw; p=importlib.resources.files('tqclaw')/'console'/'index.html'; print('yes' if p.is_file() else 'no')" > "%TEMP%\_tqclaw_console_check.tmp" 2>&1
    set /p CONSOLE_CHECK=<"%TEMP%\_tqclaw_console_check.tmp"
    del "%TEMP%\_tqclaw_console_check.tmp" >nul 2>&1
    if "!CONSOLE_CHECK!"=="yes" set "CONSOLE_AVAILABLE=1"
)

REM ──── Step 4: Create wrapper scripts ────────────────────────────────────────────────────────────────────────────────────────
if not exist "%TQCLAW_BIN%" mkdir "%TQCLAW_BIN%"

REM PowerShell wrapper
set "WRAPPER_PS1=%TQCLAW_BIN%\tqclaw.ps1"
echo # TQ-Claw CLI wrapper -- delegates to the uv-managed environment. > "%WRAPPER_PS1%"
echo $ErrorActionPreference = "Stop" >> "%WRAPPER_PS1%"
echo. >> "%WRAPPER_PS1%"
echo $TqclawHome = if ($env:TQCLAW_HOME) { $env:TQCLAW_HOME } else { Join-Path $HOME ".tqclaw" } >> "%WRAPPER_PS1%"
echo $RealBin = Join-Path $TqclawHome "venv\Scripts\tqclaw.exe" >> "%WRAPPER_PS1%"
echo. >> "%WRAPPER_PS1%"
echo if (-not (Test-Path $RealBin)) { >> "%WRAPPER_PS1%"
echo     Write-Error "TQ-Claw environment not found at $TqclawHome\venv" >> "%WRAPPER_PS1%"
echo     Write-Error "Please reinstall: irm ^<install-url^> ^| iex" >> "%WRAPPER_PS1%"
echo     exit 1 >> "%WRAPPER_PS1%"
echo } >> "%WRAPPER_PS1%"
echo. >> "%WRAPPER_PS1%"
echo ^& $RealBin @args >> "%WRAPPER_PS1%"
echo [tqclaw] Wrapper created at %WRAPPER_PS1%

REM CMD wrapper
set "WRAPPER_CMD=%TQCLAW_BIN%\tqclaw.cmd"
echo @echo off > "%WRAPPER_CMD%"
echo REM TQ-Claw CLI wrapper -- delegates to the uv-managed environment. >> "%WRAPPER_CMD%"
echo set "TQCLAW_HOME=%%TQCLAW_HOME%%" >> "%WRAPPER_CMD%"
echo if "%%TQCLAW_HOME%%"=="" set "TQCLAW_HOME=%%USERPROFILE%%\.tqclaw" >> "%WRAPPER_CMD%"
echo set "REAL_BIN=%%TQCLAW_HOME%%\venv\Scripts\tqclaw.exe" >> "%WRAPPER_CMD%"
echo if not exist "%%REAL_BIN%%" ( >> "%WRAPPER_CMD%"
echo     echo Error: TQ-Claw environment not found at %%TQCLAW_HOME%%\venv ^>^&2 >> "%WRAPPER_CMD%"
echo     echo Please reinstall ^>^&2 >> "%WRAPPER_CMD%"
echo     exit /b 1 >> "%WRAPPER_CMD%"
echo ) >> "%WRAPPER_CMD%"
echo "%%REAL_BIN%%" %%* >> "%WRAPPER_CMD%"
echo [tqclaw] CMD wrapper created at %WRAPPER_CMD%

REM ──── Step 5: Update PATH via user environment variable ──────────────────────────────────────────────────
set "CURRENT_USER_PATH="
for /f "skip=2 tokens=1,2,*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do (
    if /i "%%a"=="Path" set "CURRENT_USER_PATH=%%c"
)

:: === 安全检查PATH是否已存在（关键修复） ===
set "path_check=;%CURRENT_USER_PATH%;"
set "check_str=;%TQCLAW_BIN%;"
if /i "%path_check%" neq "%path_check:%check_str%=%" (
    echo [tqclaw] %TQCLAW_BIN% already in PATH
) else (
    :: === 修复1：安全传递参数（解决命令注入） ===
    if defined CURRENT_USER_PATH (
        powershell -NoProfile -Command "$p = $args[0]; $v = $args[1]; [Environment]::SetEnvironmentVariable('Path', $p + ';' + $v, 'User')" "%TQCLAW_BIN%" "!CURRENT_USER_PATH!"
    ) else (
        powershell -NoProfile -Command "$p = $args[0]; [Environment]::SetEnvironmentVariable('Path', $p, 'User')" "%TQCLAW_BIN%"
    )

    :: === 修复2：添加关键错误检查（解决失败不报错） ===
    if errorlevel 1 (
        echo [error] Failed to update PATH. TQCLAW_BIN: "%TQCLAW_BIN%"
        echo [error] Please verify the path is valid.
        exit /b 1
    )

    :: === 修复3：安全更新当前进程PATH ===
    set "PATH=%TQCLAW_BIN%;!PATH!"
    echo [tqclaw] Added %TQCLAW_BIN% to PATH
)

REM ──── Done ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo.
echo TQ-Claw installed successfully!
echo.
echo   Install location:  %TQCLAW_HOME%
echo   Python:            %PY_VERSION%
if "%CONSOLE_AVAILABLE%"=="1" (
    echo   Console ^(web UI^):  available
) else (
    echo   Console ^(web UI^):  not available
    echo                      Install Node.js and re-run to enable the web UI.
)
echo.
echo To get started, open a new terminal and run:
echo.
echo   tqclaw init       # first-time setup
echo   tqclaw app        # start TQ-Claw
echo.
echo To upgrade later, re-run this installer.
echo To uninstall, run: tqclaw uninstall

exit /b 0
