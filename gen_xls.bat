@echo off
REM
REM common\gen_xls.bat — 一键编译 xlsx 游戏配置 (Windows)
REM
REM 用法（从主仓根）：
REM   .\common\gen_xls.bat [mode]      REM mode: all(默认)/client/server
REM 或经控制台：
REM   .\main.sh xls [mode]
REM
setlocal
set SCRIPT_DIR=%~dp0
set MODE=%1
if "%MODE%"=="" set MODE=all

cd /d "%SCRIPT_DIR%game_conf"
call run_me.bat %MODE%
endlocal
