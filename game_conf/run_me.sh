#!/bin/bash
#
# game_conf/run_me.sh - xlsx config generator (minimal launcher)
#
# Env overrides (set by common/gen_xls.sh; EMPTY value = skip that output):
#   XLSX_DIR TEXT_DIR PROTO_DIR CODE_DIR JSON_DIR BYTES_DIR LUA_DIR
#   GEN_MODE MODULE PB_PATH PROTO_SRC
# Defaults below apply when a variable is UNDEFINED (running this script
# directly in game_conf/ still works).
#
set -euo pipefail

CONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SYSTEM=$(go env GOOS)
BIN="${CONF_DIR}/cfgtool"
[ "${SYSTEM}" = "windows" ] && BIN="${CONF_DIR}/cfgtool.exe"

if [ ! -f "${BIN}" ]; then
    echo "[ERROR] ${BIN} not found. Build it: ./main.sh build cfgtool" >&2
    exit 1
fi

# defaults when unset or empty ("-" = explicitly disabled, skip that output)
# NOTE: relative paths are resolved against the current dir (game_conf/),
# which keeps Git-Bash -> Windows cfgtool.exe argument conversion working.
: "${XLSX_DIR:=./xls}"
: "${TEXT_DIR:=../game_data}"
: "${PROTO_DIR:=../game_proto/config}"
: "${CODE_DIR:=../../module/gamedata/repository}"
: "${GEN_MODE:=all}"
: "${MODULE:=github.com/Iori372552686/GoOne}"
: "${PB_PATH:=github.com/Iori372552686/g1_common/protocol}"
: "${PROTO_SRC:=../game_proto;../../api/proto}"
# optional outputs: default empty = not generated
: "${JSON_DIR:=}"
: "${BYTES_DIR:=}"
: "${LUA_DIR:=}"

skip() { [ -n "$1" ] && [ "$1" != "-" ]; }

ARGS=(-xlsx="${XLSX_DIR}" -mode="${GEN_MODE}")
skip "${TEXT_DIR}"  && ARGS+=(-text="${TEXT_DIR}")
skip "${PROTO_DIR}" && ARGS+=(-proto="${PROTO_DIR}")
skip "${CODE_DIR}"  && ARGS+=(-code="${CODE_DIR}")
skip "${JSON_DIR}"  && ARGS+=(-json="${JSON_DIR}")
skip "${BYTES_DIR}" && ARGS+=(-bytes="${BYTES_DIR}")
skip "${LUA_DIR}"   && ARGS+=(-lua="${LUA_DIR}")
ARGS+=(-module="${MODULE}" -pb="${PB_PATH}" -proto-src="${PROTO_SRC}")

for d in "${TEXT_DIR}" "${PROTO_DIR}" "${CODE_DIR}" "${JSON_DIR}" "${BYTES_DIR}" "${LUA_DIR}"; do
    skip "${d}" && mkdir -p "${d}"
done

echo "==> 生成配置（mode=${GEN_MODE}）..."
"${BIN}" "${ARGS[@]}"

echo "[OK] configs generated:"
skip "${TEXT_DIR}"  && echo "  - runtime data (.conf): ${TEXT_DIR}/"
skip "${PROTO_DIR}" && echo "  - config protos:        ${PROTO_DIR}/"
skip "${CODE_DIR}"  && echo "  - lookup code:          ${CODE_DIR}/"
skip "${JSON_DIR}"  && echo "  - client data (.json):  ${JSON_DIR}/"
