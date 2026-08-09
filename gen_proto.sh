#!/bin/bash
#
# common/gen_proto.sh — 一键编译 g1_common 协议 proto
#
# 生成 common/protocol/*.pb.go（package g1_protocol）。
# 依赖主仓的 lib/contrib/protoc 二进制和 Go 工具链，需从主仓根目录调用。
#
# 用法（从主仓根）：
#   ./common/gen_proto.sh
# 或经控制台：
#   ./main.sh proto game
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/game_proto"

./gen_code.sh
