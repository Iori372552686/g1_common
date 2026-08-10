@echo off
REM
REM common\gen_proto.bat - one-shot compile of g1_common protocol protos (Windows)
REM
REM Usage (from the main repo root):
REM   .\common\gen_proto.bat
REM or via Git-Bash/WSL:
REM   ./main.sh proto game
REM
REM NOTE: keep this file ASCII-only; cmd.exe on GBK consoles mis-parses
REM UTF-8 Chinese comments and corrupts the following line.
REM
setlocal
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%game_proto"
call gen_code.bat
endlocal
