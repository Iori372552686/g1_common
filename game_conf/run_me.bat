@echo off
REM
REM game_conf\run_me.bat - xlsx config generator (minimal launcher)
REM
REM Env overrides (set by common\gen_xls*.bat; empty value = skip that output):
REM   XLSX_DIR TEXT_DIR PROTO_DIR CODE_DIR JSON_DIR BYTES_DIR LUA_DIR
REM   GEN_MODE MODULE PB_PATH PROTO_SRC
REM Defaults below apply when a variable is UNDEFINED (double-click here works).
REM
REM NOTE: keep ASCII-only; cmd.exe on GBK consoles mis-parses UTF-8 comments.
REM
setlocal

for /f "tokens=2 delims=:" %%i in ('chcp') do set "_SAVED_CP=%%i"
chcp 65001 >nul

set BIN=%~dp0cfgtool.exe
if not exist "%BIN%" (
    echo [ERROR] %BIN% not found. Build it: .\main.sh build cfgtool
    if defined _SAVED_CP chcp %_SAVED_CP% >nul
    exit /b 1
)

if not defined XLSX_DIR  set XLSX_DIR=%~dp0xls
if not defined TEXT_DIR  set TEXT_DIR=%~dp0..\game_data
if not defined PROTO_DIR set PROTO_DIR=%~dp0..\game_proto\config
if not defined CODE_DIR  set CODE_DIR=%~dp0..\..\module\gamedata\repository
if not defined GEN_MODE  set GEN_MODE=all
if not defined MODULE    set MODULE=github.com/Iori372552686/GoOne
if not defined PB_PATH   set PB_PATH=github.com/Iori372552686/g1_common/protocol
if not defined PROTO_SRC set PROTO_SRC=%~dp0..\game_proto;%~dp0..\..\api\proto

set ARGS=-xlsx="%XLSX_DIR%" -mode=%GEN_MODE%
if not "%TEXT_DIR%"==""  if not "%TEXT_DIR%"=="-"  set ARGS=%ARGS% -text="%TEXT_DIR%"
if not "%PROTO_DIR%"=="" if not "%PROTO_DIR%"=="-" set ARGS=%ARGS% -proto="%PROTO_DIR%"
if not "%CODE_DIR%"==""  if not "%CODE_DIR%"=="-"  set ARGS=%ARGS% -code="%CODE_DIR%"
if not "%JSON_DIR%"==""  if not "%JSON_DIR%"=="-"  set ARGS=%ARGS% -json="%JSON_DIR%"
if not "%BYTES_DIR%"=="" if not "%BYTES_DIR%"=="-" set ARGS=%ARGS% -bytes="%BYTES_DIR%"
if not "%LUA_DIR%"==""   if not "%LUA_DIR%"=="-"   set ARGS=%ARGS% -lua="%LUA_DIR%"
set ARGS=%ARGS% -module=%MODULE% -pb=%PB_PATH% -proto-src=%PROTO_SRC%

for %%d in ("%TEXT_DIR%" "%PROTO_DIR%" "%CODE_DIR%" "%JSON_DIR%" "%BYTES_DIR%" "%LUA_DIR%") do if not "%%~d"=="" if not "%%~d"=="-" mkdir "%%~d" 2>nul

echo ^>^>^> generating configs ^(mode=%GEN_MODE%^) ...
"%BIN%" %ARGS%
set _rc=%ERRORLEVEL%
if not %_rc%==0 (
    echo [ERROR] generation failed ^(exit code %_rc%^)
    if defined _SAVED_CP chcp %_SAVED_CP% >nul
    exit /b %_rc%
)

echo [OK] configs generated:
if not "%TEXT_DIR%"==""  if not "%TEXT_DIR%"=="-"  echo   - runtime data (.conf): %TEXT_DIR%\
if not "%PROTO_DIR%"=="" if not "%PROTO_DIR%"=="-" echo   - config protos:        %PROTO_DIR%\
if not "%CODE_DIR%"==""  if not "%CODE_DIR%"=="-"  echo   - lookup code:          %CODE_DIR%\
if not "%JSON_DIR%"==""  if not "%JSON_DIR%"=="-"  echo   - client data (.json):  %JSON_DIR%\

if defined _SAVED_CP chcp %_SAVED_CP% >nul
endlocal
