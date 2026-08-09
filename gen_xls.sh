#!/bin/bash
#
# common/gen_xls.sh — 一键编译 xlsx 游戏配置
#
# 读取 common/game_conf/xls/*.xlsx，生成运行时配置(.conf)、proto、Go查询代码。
#
# 用法（从主仓根）：
#   ./common/gen_xls.sh [mode]      # mode: all(默认)/client/server
# 或经控制台：
#   ./main.sh xls [mode]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-all}"

cd "${SCRIPT_DIR}/game_conf"
./run_me.sh "${MODE}"
