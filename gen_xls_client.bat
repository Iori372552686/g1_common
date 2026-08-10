@echo off
REM
REM common\gen_xls_client.bat - one-click CLIENT config export (mode=client)
REM
REM Run from the main repo root:  .\common\gen_xls_client.bat
REM
REM Environment lives HERE. Client output dirs are TEMPORARY placeholders
REM (%TEMP%\g1_client_output\...) - point them at the real client repo
REM paths below when they are decided. proto/code are server-side outputs
REM and are intentionally disabled (empty) for client export.
REM
REM NOTE: keep ASCII-only; cmd.exe on GBK consoles mis-parses UTF-8 comments.
REM
setlocal
set SCRIPT_DIR=%~dp0

REM ---- environment (edit here) ----
for %%i in ("%SCRIPT_DIR%..") do set REPO_ROOT=%%~fi
set XLSX_DIR=%SCRIPT_DIR%game_conf\xls
REM ---- temporary client outputs, change later ----
set TEXT_DIR=%TEMP%\g1_client_output\conf
set JSON_DIR=%TEMP%\g1_client_output\json
REM ---- server-side outputs, disabled for client ("-" = skip) ----
set PROTO_DIR=-
set CODE_DIR=-
set GEN_MODE=client
set MODULE=github.com/Iori372552686/GoOne
set PB_PATH=github.com/Iori372552686/g1_common/protocol
set PROTO_SRC=%SCRIPT_DIR%game_proto;%REPO_ROOT%\api\proto

call "%SCRIPT_DIR%game_conf\run_me.bat"
set _rc=%ERRORLEVEL%

echo.
echo [done] press any key to exit...
pause >nul
endlocal
exit /b %_rc%
