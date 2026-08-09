@echo off
REM
REM game_conf\run_me.bat — 一键编译 xls 配置 (Windows)
REM
REM 从 common\game_conf\ 目录运行。读取 .\xls\*.xlsx，生成：
REM   - pb text (.conf) -^> ..\..\module\gamedata\data\
REM   - proto 定义      -^> ..\game_proto\config\
REM   - Go 查询代码     -^> ..\..\module\gamedata\repository\
REM
REM 用法：
REM   run_me.bat              REM 默认全量生成
REM   run_me.bat server       REM 仅服务端
REM
REM 也可经主仓控制台：.\main.sh xls
REM
setlocal

set CONF_MODE=%1
if "%CONF_MODE%"=="" set CONF_MODE=all

set BIN=cfgtool.exe
if not exist "%BIN%" (
    echo 错误：找不到 %BIN%
    echo 请先编译：在主仓根目录执行 .\main.sh build cfgtool 或 .\build.ps1 cfgtool
    exit /b 1
)

set DATA_DIR=..\..\module\gamedata\data
set REPO_DIR=..\..\module\gamedata\repository
set PROTO_DIR=..\game_proto\config

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%REPO_DIR%" mkdir "%REPO_DIR%"
if not exist "%PROTO_DIR%" mkdir "%PROTO_DIR%"

echo ^>^>^> 生成配置（mode=%CONF_MODE%）...
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
    echo ✗ 生成失败
    exit /b 1
)

echo ✓ 配置生成完成
echo   - 运行时数据(.conf): %DATA_DIR%\
echo   - 配置表 proto:      %PROTO_DIR%\
echo   - 查询代码(.gen.go): %REPO_DIR%\

REM 清理：cfgtool 的 -proto 输出可能混入 core/service/storage proto，
REM 只保留配置表 proto（enum_config/global_config/struct_config/xlsx_config）。
for %%f in ("%PROTO_DIR%\*.proto") do (
    echo %%~nxf | findstr /r "enum_config global_config struct_config xlsx_config" >nul || del "%%f"
)

endlocal
