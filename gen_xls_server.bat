@echo off
REM
REM common\gen_xls_server.bat - one-click SERVER config export (mode=server)
REM
REM Run from the main repo root:  .\common\gen_xls_server.bat
REM
REM Environment lives HERE (edit paths in the section below if they change).
REM
REM NOTE: keep ASCII-only; cmd.exe on GBK consoles mis-parses UTF-8 comments.
REM
setlocal
set SCRIPT_DIR=%~dp0

REM ---- environment (edit here) ----
for %%i in ("%SCRIPT_DIR%..") do set REPO_ROOT=%%~fi
set XLSX_DIR=%SCRIPT_DIR%game_conf\xls
set TEXT_DIR=%SCRIPT_DIR%game_data
set PROTO_DIR=%SCRIPT_DIR%game_proto\config
set CODE_DIR=%REPO_ROOT%\module\gamedata\repository
set GEN_MODE=server
set MODULE=github.com/Iori372552686/GoOne
set PB_PATH=github.com/Iori372552686/g1_common/protocol
set PROTO_SRC=%SCRIPT_DIR%game_proto;%REPO_ROOT%\api\proto

REM run_me.bat takes over from here (no call - it owns the tail: pause + exit code)
"%SCRIPT_DIR%game_conf\run_me.bat"
