@echo off
REM
REM game_conf\run_me.bat - one-shot compile of xlsx configs (Windows)
REM
REM Run from common\game_conf\. Reads .\xls\*.xlsx and generates:
REM   - pb text (.conf)    -> ..\game_data\
REM   - proto definitions  -> ..\game_proto\config\
REM   - Go lookup code     -> ..\..\module\gamedata\repository\
REM
REM Usage:
REM   run_me.bat            full generation (default)
REM   run_me.bat server     server only
REM
REM Or from the main repo console: .\main.sh xls
REM
REM NOTE: keep this file ASCII-only; cmd.exe on GBK consoles mis-parses
REM UTF-8 Chinese comments and corrupts the following line.
REM
setlocal

REM cfgtool prints UTF-8 Chinese logs; switch the console to UTF-8 so they
REM render correctly on GBK (CP936) consoles, then restore the codepage.
for /f "tokens=2 delims=:" %%i in ('chcp') do set "_SAVED_CP=%%i"
chcp 65001 >nul

set CONF_MODE=%1
if "%CONF_MODE%"=="" set CONF_MODE=all

set BIN=cfgtool.exe
if not exist "%BIN%" (
    echo [ERROR] cfgtool.exe not found. Build it first:
    echo   from the main repo root: .\main.sh build cfgtool  or  .\build.ps1 cfgtool
    exit /b 1
)

set DATA_DIR=..\game_data
set REPO_DIR=..\..\module\gamedata\repository
set PROTO_DIR=..\game_proto\config

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%REPO_DIR%" mkdir "%REPO_DIR%"
if not exist "%PROTO_DIR%" mkdir "%PROTO_DIR%"

echo ^>^>^> generating configs (mode=%CONF_MODE%) ...
"%BIN%" ^
    -xlsx=.\xls ^
    -text="%DATA_DIR%" ^
    -proto="%PROTO_DIR%" ^
    -code="%REPO_DIR%" ^
    -mode=%CONF_MODE% ^
    -module=github.com/Iori372552686/GoOne ^
    -pb=github.com/Iori372552686/g1_common/protocol ^
    -proto-src=..\game_proto\core

if errorlevel 1 (
    echo [ERROR] generation failed
    exit /b 1
)

echo [OK] configs generated:
echo   - runtime data (.conf): %DATA_DIR%\
echo   - config protos:        %PROTO_DIR%\
echo   - lookup code:          %REPO_DIR%\

REM No cleanup loop here: cfgtool's -proto output contains ONLY the generated
REM config protos (feature-based names such as drop.proto / item.proto).
REM The old whitelist (enum_config/global_config/...) is obsolete after the
REM @-naming refactor and used to wipe the freshly generated protos.

REM restore the console codepage
if defined _SAVED_CP chcp %_SAVED_CP% >nul

endlocal
