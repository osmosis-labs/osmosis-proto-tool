#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck >/dev/null && shellcheck "$0"

PROTO_DIR="./proto"
COSMOS_DIR="$PROTO_DIR/cosmos"
COSMOS_SDK_DIR="$COSMOS_DIR/cosmos-sdk"
COSMOS_SDK_VERSION="v0.47.1"

mkdir -p repos
mkdir -p "$COSMOS_SDK_DIR/proto"


# SDK PROTOS

# If the cosmos-sdk repo is there, fetch, otherwise clone sparse
if [ -d "repos/cosmos-sdk/.git" ]; then
  git -C repos/cosmos-sdk fetch --all --tags
  git -C repos/cosmos-sdk checkout $COSMOS_SDK_VERSION 
  git -C repos/cosmos-sdk pull origin $COSMOS_SDK_VERSION
else
  git clone --filter=blob:none --sparse https://github.com/cosmos/cosmos-sdk.git repos/cosmos-sdk
  
  # Checkout the cosmos-sdk version
  git -C repos/cosmos-sdk sparse-checkout set proto
  git -C repos/cosmos-sdk checkout $COSMOS_SDK_VERSION
fi

# Move the protos folder to the desired destination
cp -R repos/cosmos-sdk/proto/cosmos "$COSMOS_SDK_DIR/proto/cosmos" || true


# OSMOSIS PROTOS

# If the osmosis repo is there, fetch, otherwise clone sparse
if [ -d "repos/osmosis/.git" ]; then
  git -C repos/osmosis fetch --all --tags
  git -C repos/osmosis checkout main
  git -C repos/osmosis pull origin main
else
  git clone --filter=blob:none --sparse https://github.com/osmosis-labs/osmosis.git repos/osmosis

  # Move to the osmosis repo directory and set sparse-checkout for the /proto folder
  git -C repos/osmosis sparse-checkout set proto
fi

# Check if the osmosis commit hash is provided and checkout to that commit
if [ $# -gt 0 ]; then
  OSMOSIS_COMMIT_HASH="$1"
  git -C repos/osmosis pull origin $OSMOSIS_COMMIT_HASH
  git -C repos/osmosis checkout $OSMOSIS_COMMIT_HASH
fi

# Move the osmosis/proto/osmosis folder to the desired destination
cp -R repos/osmosis/proto/osmosis "$COSMOS_SDK_DIR/proto/osmosis" || true


# IBC PROTOS

# Extract the IBC Go version from the go.mod file
IBC_GO_VERSION=$(awk '/github.com\/cosmos\/ibc-go/ {print $2}' repos/osmosis/go.mod)

# If the ibc-go repo is there, fetch, otherwise clone sparse
if [ -d "repos/ibc-go/.git" ]; then
  git -C repos/ibc-go fetch --all --tags
  git -C repos/ibc-go checkout $IBC_GO_VERSION
  git -C repos/ibc-go pull origin $IBC_GO_VERSION
else
  git clone --filter=blob:none --sparse https://github.com/cosmos/ibc-go.git repos/ibc-go
  # Checkout extracted version
  git -C repos/ibc-go sparse-checkout set proto
  git -C repos/ibc-go checkout $IBC_GO_VERSION
fi

# Move IBC Go proto files into the $COSMOS_SDK_DIR/proto directory
cp -R repos/ibc-go/proto/* "$COSMOS_SDK_DIR/proto/" || true


# WASMD PROTOS

# Extract the Wasmd version from the go.mod file
WASMD_VERSION=$(awk '/github.com\/osmosis-labs\/wasmd/ {print $4}' repos/osmosis/go.mod)

# Clone or update the wasmd repo (osmosis-labs fork)
# If the wasmd repo is there, fetch, otherwise clone sparse
if [ -d "repos/wasmd/.git" ]; then
  git -C repos/wasmd fetch --all --tags
  git -C repos/wasmd checkout $WASMD_VERSION
  git -C repos/wasmd pull origin $WASMD_VERSION
else
  git clone --filter=blob:none --sparse https://github.com/osmosis-labs/wasmd.git repos/wasmd
  git -C repos/wasmd sparse-checkout set proto
  git -C repos/wasmd checkout $WASMD_VERSION
fi


# Move Wasmd proto files into the $COSMOS_SDK_DIR/proto directory
mkdir -p $COSMOS_SDK_DIR/proto/cosmwasm/
cp -R repos/wasmd/proto/cosmwasm/wasm/v1/* "$COSMOS_SDK_DIR/proto/cosmwasm/" || true
