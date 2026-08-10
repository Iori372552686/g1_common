#!/bin/bash
#
# common/gen_xls.sh - one-click xlsx config generation
#
# Usage (from the main repo root):
#   ./common/gen_xls.sh [all|client|server]   # default: server
# or via console:  ./main.sh xls [mode]
#
# Environment lives HERE. client outputs go to a TEMPORARY dir
# (${TMPDIR}/g1_client_output/...) - point them at the real client repo
# paths below when they are decided. proto/code are server-side outputs
# and are intentionally disabled (empty) for client export.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-server}"

case "${MODE}" in
  all|server)
    # ---- environment (edit here; paths are relative to game_conf/) ----
    XLSX_DIR=./xls
    TEXT_DIR=../game_data
    PROTO_DIR=../game_proto/config
    CODE_DIR=../../module/gamedata/repository
    ;;
  client)
    # ---- environment (edit here; paths are relative to game_conf/) ----
    XLSX_DIR=./xls
    # ---- temporary client outputs, change later ----
    TEXT_DIR="${TMPDIR:-/tmp}/g1_client_output/conf"
    JSON_DIR="${TMPDIR:-/tmp}/g1_client_output/json"
    # ---- server-side outputs, disabled for client ("-" = skip) ----
    PROTO_DIR=-
    CODE_DIR=-
    ;;
  *)
    echo "unknown mode: ${MODE} (supported: all/client/server)" >&2
    exit 1
    ;;
esac

# export all outputs to run_me.sh (unset ones export as empty = skipped there)
export XLSX_DIR TEXT_DIR PROTO_DIR CODE_DIR JSON_DIR BYTES_DIR LUA_DIR
export GEN_MODE="${MODE}"
export MODULE=github.com/Iori372552686/GoOne
export PB_PATH=github.com/Iori372552686/g1_common/protocol
# paths are relative to game_conf/ (run_me.sh resolves them there)
export PROTO_SRC="../game_proto;../../api/proto"

cd "${SCRIPT_DIR}/game_conf"
./run_me.sh
