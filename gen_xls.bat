@echo off
REM
REM common\gen_xls.bat - one-shot compile of xlsx game configs (Windows)
REM
REM Usage (from the main repo root):
REM   .\common\gen_xls.bat [mode]     REM mode: all (default) / client / server
REM or via Git-Bash/WSL:
REM   ./main.sh xls [mode]
REM
REM NOTE: keep this file ASCII-only; cmd.exe on GBK consoles mis-parses
REM UTF-8 Chinese comments and corrupts the following line.
REM
setlocal
set SCRIPT_DIR=%~dp0
set MODE=%1
if "%MODE%"=="" set MODE=all

cd /d "%SCRIPT_DIR%game_conf"
call run_me.bat %MODE%
endlocal
