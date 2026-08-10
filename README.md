# g1_common

GoOne 项目的共享公共仓库（作为主仓 [GoOne](https://github.com/Iori372552686/GoOne) 的 submodule）。

## 目录结构

```
g1_common/
├── game_proto/          # 协议 proto 源文件 + 生成脚本
│   ├── core/            # 核心共享消息（client/cmd/common/role/room/struct/...）
│   ├── config/          # 配置表 proto（由 cfgtool 从 xlsx 生成）
│   ├── service/         # 各服务的 service proto（ssrpc IDL）
│   ├── storage/         # 存储 KV 抽象 proto
│   ├── gen_code.sh      # proto → .pb.go 生成脚本（Linux/macOS）
│   └── gen_code.bat     # proto → .pb.go 生成脚本（Windows）
│
├── protocol/            # 生成的 *.pb.go（package g1_protocol，禁止手改）
│   └── *.pb.go

│
├── game_conf/           # xlsx → 配置 工具链
│   ├── cfgtool          # Linux 二进制
│   ├── cfgtool.exe      # Windows 二进制
│   ├── xls/             # 策划填写的 xlsx 源表（唯一数据源）
│   ├── run_me.sh        # 一键生成脚本
│   ├── run_me.bat
│   └── readme.md        # 详细使用说明
│
├── game_data/           # 运行时配置数据（.conf，由 cfgtool 从 xlsx 生成）
│   ├── *.conf           # pb text 格式，服务启动时 gamedata.InitLocal 读取
│   └── gamedata.tar     # 打包归档（部署用）
│
├── sensitive/           # 敏感词表
│   └── sensitive.txt
│
├── gen_proto.sh         # 一键编译 proto（调 game_proto/gen_code.sh）
├── gen_proto.bat
├── gen_xls.sh           # 一键编译 xls 配置（调 game_conf/run_me.sh）
├── gen_xls.bat
├── go.mod               # module github.com/Iori372552686/g1_common
└── README.md            # 本文档
```

## 使用方式

### 从主仓控制台调用（推荐）

本仓库作为主仓的 submodule，通常**从主仓根目录**经 `main.sh` 控制台调用：

```bash
./main.sh proto game     # 生成 protocol/*.pb.go
./main.sh xls            # 生成 xlsx 配置（.conf + repository/.gen.go）
./main.sh build cfgtool  # 重新编译 cfgtool 二进制到 game_conf/
```

### 直接调用

也可以在 `common/` 目录下直接运行：

```bash
./gen_proto.sh                       # 生成 proto
./gen_xls.sh                         # 生成 xls 配置（mode=all）
./gen_xls.sh server                  # 仅服务端配置

# 或进入子目录直接调底层脚本：
cd game_proto && ./gen_code.sh
cd game_conf && ./run_me.sh
```

## 依赖

proto 和 xls 生成**依赖主仓**：
- `lib/contrib/protoc/`：protoc 二进制（gen_code.sh 用）
- Go 工具链（编译 protoc-gen-go 插件、cfgtool）
- `tools/cfgtool/`：cfgtool 源码（编译二进制）

因此生成脚本需在主仓环境中运行（主仓根目录或经 `main.sh`）。

## Go Module

```
module github.com/Iori372552686/g1_common
```

主仓通过 `replace github.com/Iori372552686/g1_common => ./common` 引用。

## 重要约定

- `protocol/*.pb.go` 是**生成代码，禁止手改**。改 proto 后跑 `./main.sh proto game` 重新生成。
- `game_conf/xls/` 是配置表**唯一数据源**。禁止直接改 `.conf` 或 `.gen.go`。
- 配置表的 Go 查询代码（`repository/*.gen.go`）生成在主仓的 `module/gamedata/repository/`（不在本仓库），因为它们依赖主仓的 `module/gamedata` 包。
