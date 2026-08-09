@echo off
REM
REM common\gen_proto.bat — 一键编译 g1_common 协议 proto (Windows)
REM
REM 用法（从主仓根）：
REM   .\common\gen_proto.bat
REM 或经控制台：
REM   .\main.sh proto game
REM
setlocal
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%game_proto"
call gen_code.bat
endlocal
