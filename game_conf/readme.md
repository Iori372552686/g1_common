# game_conf — 游戏配置表工具链

本目录是 GoOne 的 **xlsx → 配置** 工具链，属于 `g1_common` 仓库的一部分。

## 目录结构

```
game_conf/
├── cfgtool          # Linux 二进制（由主仓 tools/cfgtool/ 编译）
├── cfgtool.exe      # Windows 二进制
├── xls/             # 策划填写的 xlsx 源表（唯一数据源）
├── run_me.sh        # Linux/macOS 一键生成脚本
├── run_me.bat       # Windows 一键生成脚本
└── readme.md        # 本文档
```

## 快速使用

### 一键生成（推荐）

在 `common/game_conf/` 目录下：

```bash
# Linux / macOS / Git-Bash
./run_me.sh              # 全量生成（mode=all）
./run_me.sh server       # 仅服务端配置

# Windows
run_me.bat
run_me.bat server
```

或经**主仓控制台**（从主仓根目录）：

```bash
./main.sh xls            # 一键生成
```

### 生成产物

运行后产出三部分：

| 产物 | 输出路径 | 说明 |
|------|---------|------|
| 运行时数据 `.conf` | `../../module/gamedata/data/` | pb text 格式，服务启动时由 `gamedata.InitLocal` 读取 |
| 配置表 proto | `../game_proto/config/` | xlsx 结构对应的 proto 定义 |
| Go 查询代码 `.gen.go` | `../../module/gamedata/repository/` | 每个表一个包，含 `GetById/Filter/Range` 等查询 API |

## 重新编译二进制

cfgtool 二进制由主仓 `tools/cfgtool/` 源码编译。更新工具源码后，在主仓根目录：

```bash
./main.sh build cfgtool              # 默认（无 etcd 后端）
# 或
./build.sh cfgtool && cp build/cfgtool common/game_conf/cfgtool

# etcd 上传后端（需 build tag）
GO_BUILD_TAGS=config_etcd ./main.sh build cfgtool
```

> Windows 用 `.\build.ps1 cfgtool`。

## cfgtool 命令参数

`cfgtool` 支持以下参数（`cfgtool --help` 查看）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-xlsx` | xlsx 源目录 | `./xls` |
| `-text` | pb text(.conf) 输出目录 | 空（不生成） |
| `-proto` | proto 定义输出目录 | 空 |
| `-code` | Go 代码输出目录 | 空 |
| `-json` | JSON 输出目录 | 空 |
| `-bytes` | pb bytes 输出目录 | 空 |
| `-lua` | Lua 输出目录 | 空 |
| `-mode` | 生成模式（all/client/server） | `all` |
| `-module` | 生成代码的 module 路径 | `github.com/Iori372552686/GoOne` |
| `-pb` | proto 生成的包路径 | `github.com/Iori372552686/g1_common/protocol` |
| `-proto-src` | 外部 proto 源目录（用于 pb.XXX 引用） | 空 |
| `-upload` | 配置中心 URL（留空不上传） | 空 |
| `-uptype` | 上传格式（json/conf/bytes/lua） | 空 |

详细语法（xlsx 表结构、分隔符规则、类型支持等）见主仓 `tools/cfgtool/README.md`。

## 上传到配置中心

cfgtool 支持把生成的配置发布到配置中心（复用 `lib/contrib/config` 地址解析）：

```bash
# 上传 .conf 到 etcd 开发环境（需 -tags config_etcd 编译）
./cfgtool -xlsx=./xls -text=./gen/text -proto=./gen/proto \
    -upload="etcd://host:2379?path=/goone/config/dev" -uptype=conf

# 上传到 nacos
./cfgtool -xlsx=./xls -text=./gen/text -json=./gen/json \
    -upload="nacos://host:8848?group=GOONE_CONFIG&namespace_id=public" -uptype=conf,json
```

> **读取端契约**：服务器 `gamedata` 当前生产读取端只接了 Nacos。etcd 读取需补路径前缀剥离适配（详见主仓 `tools/cfgtool/README.md`）。

## 注意事项

- **xlsx 是唯一数据源**。禁止直接修改 `.conf` 或 `.gen.go`（它们是生成产物）。
- `.gen.go` 由 `init()` 自动注册到 `gamedata`，勿手动改名。
- 服务器侧 `gamedata` 的 parser 只认 `.conf`（pb text）格式，JSON/bytes 仅供客户端/工具链。
