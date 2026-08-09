#!/bin/bash
#
# game_conf/run_me.sh — 一键编译 xls 配置
#
# 从 common/game_conf/ 目录运行。读取 ./xls/*.xlsx，生成：
#   - pb text (.conf) → ../game_data/                      （运行时配置）
#   - proto 定义      → ../game_proto/config/               （配置表 proto）
#   - Go 查询代码     → ../../module/gamedata/repository/   （生成 .gen.go）
#
# 用法：
#   ./run_me.sh              # 默认全量生成
#   ./run_me.sh server       # 仅服务端（mode=server）
#
# 也可经主仓控制台：./main.sh xls
#
set -euo pipefail

SYSTEM=$(go env GOOS)
CONF_MODE="${1:-all}"

# 定位二进制
if [ "${SYSTEM}" = "windows" ]; then
    BIN=./cfgtool.exe
else
    BIN=./cfgtool
fi

if [ ! -x "${BIN}" ] && [ ! -f "${BIN}" ]; then
    echo "错误：找不到 cfgtool 二进制（${BIN}）" >&2
    echo "请先编译：在主仓根目录执行 ./main.sh build cfgtool" >&2
    exit 1
fi

# 输出目录（相对 common/game_conf/）
DATA_DIR=../game_data
REPO_DIR=../../module/gamedata/repository
PROTO_DIR=../game_proto/config

mkdir -p "${DATA_DIR}" "${REPO_DIR}" "${PROTO_DIR}"

echo "==> 生成配置（mode=${CONF_MODE}）..."
"${BIN}" \
    -xlsx=./xls \
    -text="${DATA_DIR}" \
    -proto="${PROTO_DIR}" \
    -code="${REPO_DIR}" \
    -mode="${CONF_MODE}" \
    -module=github.com/Iori372552686/GoOne \
    -pb=github.com/Iori372552686/g1_common/protocol \
    -proto-src=../game_proto/core

echo "✓ 配置生成完成"
echo "  - 运行时数据(.conf): ${DATA_DIR}/"
echo "  - 配置表 proto:      ${PROTO_DIR}/"
echo "  - 查询代码(.gen.go): ${REPO_DIR}/"

# 清理：cfgtool 的 -proto 输出可能混入 -proto-src 扫描到的 core/service/storage proto，
# 只保留配置表 proto（enum_config/global_config/struct_config/xlsx_config）。
find "${PROTO_DIR}" -maxdepth 1 -name '*.proto' ! -name 'enum_config.proto' ! -name 'global_config.proto' ! -name 'struct_config.proto' ! -name 'xlsx_config.proto' -delete 2>/dev/null || true
