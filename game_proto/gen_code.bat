@echo off
REM
REM Generate g1_common/protocol/*.pb.go (Windows)
REM
REM Run from common/game_proto (depends on the main repo's lib/contrib/protoc
REM and the Go toolchain).
REM Usage: cd common\game_proto && gen_code.bat
REM (or run common\gen_proto.bat from the main repo root)
REM
REM NOTE: keep this file ASCII-only. cmd.exe on a GBK (CP936) console
REM mis-parses UTF-8 Chinese in comments: a line ending in a multi-byte
REM char corrupts the NEXT line (e.g. drops the leading REM token).
REM
setlocal EnableDelayedExpansion

set module=github.com/Iori372552686/g1_common
set bin_dir=.bin
REM protoc binary: prefer PROTOC_BIN_DIR env var, fall back to the main repo copy
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

REM Collect protocol-owned proto files (exclude service protos whose go_package
REM points at GoOne/api/gen). Use plain for (relative paths, NOT for /r):
REM for /r yields absolute paths, which protoc on Windows cannot resolve
REM against the relative -I. option.
for %%f in (core\*.proto config\*.proto storage\*.proto service\*.proto) do (
    if exist "%%f" (
        findstr /c:"github.com/Iori372552686/GoOne/api/gen/" "%%f" >nul 2>&1
        if errorlevel 1 (
            set proto_args=!proto_args! "%%f"
        )
    )
)

if not defined proto_args (
    echo no protocol-owned proto files found
    goto :end
)

REM Best-effort cleanup: rmdir can hit a transient sharing violation (e.g.
REM antivirus scan) - protoc overwrites in place anyway, so hide the noise.
if exist ..\protocol rmdir /s /q ..\protocol 2>nul

"%protoc_dir%\protoc.exe" -I. -I"%protoc_include%" --plugin=protoc-gen-go="%protoc_gen_go%" --go_out=.. --go_opt=module=%module% --go_opt=paths=import !proto_args!
if errorlevel 1 goto :end

if exist ..\protocol\database.pb.go (
    "%protoc_go_inject_tag%" -input=..\protocol\database.pb.go
    if errorlevel 1 goto :end
    gofmt -w ..\protocol\database.pb.go
)

REM Composite-key containers (Index2/3/4) are hand-written in
REM module/gamedata/index.go of the main repo; no longer generated or copied.

echo [OK] g1_common/protocol generated (..\protocol)

:end
endlocal
