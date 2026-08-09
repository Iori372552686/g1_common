@echo off
REM
REM 生成 g1_common/protocol/*.pb.go (Windows)
REM
REM 此脚本需从主仓根目录调用（依赖主仓 lib/contrib/protoc 和 Go 工具链）。
REM 用法：cd common\game_proto && gen_code.bat
REM 或经主仓脚本：scripts\gen_common_proto.bat
REM
setlocal EnableDelayedExpansion

set module=github.com/Iori372552686/g1_common
set bin_dir=.bin
REM protoc 二进制：优先环境变量，回退到主仓 ..\..\lib\contrib\protoc
if defined PROTOC_BIN_DIR (
    set protoc_dir=%PROTOC_BIN_DIR%\bin
    set protoc_include=%PROTOC_BIN_DIR%\include
) else (
    set protoc_dir=..\..\lib\contrib\protoc\protoc-33.2-win64\bin
    set protoc_include=..\..\lib\contrib\protoc\protoc-33.2-win64\include
)
set protoc_gen_go=%bin_dir%\protoc-gen-go.exe
set protoc_go_inject_tag=%bin_dir%\protoc-go-inject-tag.exe
set proto_args=

if not exist "%bin_dir%" mkdir "%bin_dir%"

go build -o "%protoc_gen_go%" google.golang.org/protobuf/cmd/protoc-gen-go
if errorlevel 1 goto :end

go build -o "%protoc_go_inject_tag%" github.com/favadi/protoc-go-inject-tag
if errorlevel 1 goto :end

REM 收集 protocol-owned proto 文件（排除 go_package 指向 GoOne/api/gen 的 service proto）
for /r %%f in (core\*.proto config\*.proto storage\*.proto service\*.proto) do (
    findstr /c:"github.com/Iori372552686/GoOne/api/gen/" "%%f" >nul 2>&1
    if errorlevel 1 (
        set proto_args=!proto_args! "%%f"
    )
)

if not defined proto_args (
    echo no protocol-owned proto files found
    goto :end
)

if exist ..\protocol rmdir /s /q ..\protocol

"%protoc_dir%\protoc.exe" -I. -I"%protoc_include%" --plugin=protoc-gen-go="%protoc_gen_go%" --go_out=.. --go_opt=module=%module% --go_opt=paths=import !proto_args!
if errorlevel 1 goto :end

if exist ..\protocol\database.pb.go (
    "%protoc_go_inject_tag%" -input=..\protocol\database.pb.go
    if errorlevel 1 goto :end

    REM xorm:"-" 标签后处理（与 .sh 版一致）
    powershell -NoProfile -Command "(Get-Content ..\protocol\database.pb.go) -replace '(^\s*state\s+protoimpl\.MessageState\s+`)([^`]*)(`)','${1}${2} xorm:\"-\"${3}' | Set-Content ..\protocol\database.pb.go"
    powershell -NoProfile -Command "(Get-Content ..\protocol\database.pb.go) -replace '(^\s*sizeCache\s+protoimpl\.SizeCache)\s*$','${1} `xorm:\"-\"`' | Set-Content ..\protocol\database.pb.go"
    powershell -NoProfile -Command "(Get-Content ..\protocol\database.pb.go) -replace '(^\s*unknownFields\s+protoimpl\.UnknownFields)\s*$','${1} `xorm:\"-\"`' | Set-Content ..\protocol\database.pb.go"

    gofmt -w ..\protocol\database.pb.go
)

echo ^✓ g1_common/protocol generated ^(..\protocol^)

:end
endlocal
