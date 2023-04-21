#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck >/dev/null && shellcheck "$0"

validate_proto_file() {
  # File exists
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
  fi
}

GENERATED_DIR="./tmp"
ROOT_PROTO_DIR="./proto/cosmos/cosmos-sdk"
COSMOS_PROTO_DIR="$ROOT_PROTO_DIR/proto/cosmos"
IBC_PROTO_DIR="$ROOT_PROTO_DIR/proto/ibc"
COSMWASM_PROTO_DIR="$ROOT_PROTO_DIR/proto/cosmwasm"
TENDERMINT_PROTO_DIR="$ROOT_PROTO_DIR/third_party/proto/tendermint"
OSMOSIS_PROTO_DIR="$ROOT_PROTO_DIR/proto/osmosis"

PROTO_FILES=(
  "$COSMOS_PROTO_DIR/base/v1beta1/coin.proto"
  "$COSMOS_PROTO_DIR/bank/v1beta1/bank.proto"
  "$OSMOSIS_PROTO_DIR/poolmanager/v1beta1/tx.proto"
  "$OSMOSIS_PROTO_DIR/poolmanager/v1beta1/swap_route.proto"
  "$OSMOSIS_PROTO_DIR/gamm/pool-models/balancer/balancerPool.proto"
  "$OSMOSIS_PROTO_DIR/gamm/pool-models/balancer/tx/tx.proto"
  "$OSMOSIS_PROTO_DIR/gamm/pool-models/stableswap/stableswap_pool.proto"
  "$OSMOSIS_PROTO_DIR/gamm/pool-models/stableswap/tx.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/pool-model/tx.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/incentive_record.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/pool.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/position.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/tickInfo.proto"
  "$OSMOSIS_PROTO_DIR/concentrated-liquidity/tx.proto"
  "$OSMOSIS_PROTO_DIR/superfluid/tx.proto"
  "$OSMOSIS_PROTO_DIR/lockup/lock.proto"
  "$OSMOSIS_PROTO_DIR/lockup/tx.proto"
  "$OSMOSIS_PROTO_DIR/incentives/tx.proto"
)

mkdir -p "$GENERATED_DIR"

# Validate each proto file
for proto_file in "${PROTO_FILES[@]}"; do
  validate_proto_file "$proto_file"
done

yarn pbjs \
  -t static-module \
  --es6 \
  -w commonjs \
  -o "$GENERATED_DIR/codecimpl.js" \
  --sparse \
  --no-beautify \
  --no-verify \
  --no-delimited \
  --force-long \
  "${PROTO_FILES[@]}"

# Work around https://github.com/protobufjs/protobuf.js/issues/1477
# shellcheck disable=SC2016
sed -i "" -e 's/^const \$root =.*$/const \$root = {};/' "$GENERATED_DIR/codecimpl.js"
