#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck >/dev/null && shellcheck "$0"

PROTO_DIR="./proto"
COSMOS_DIR="$PROTO_DIR/cosmos"
COSMOS_SDK_DIR="$COSMOS_DIR/cosmos-sdk"
ZIP_FILE="$COSMOS_DIR/tmp.zip"

COSMOS_SDK_VERSION="0.47.1"

mkdir -p "$COSMOS_DIR"

# get cosmos sdk proto files from zip archive
wget -qO "$ZIP_FILE" "https://github.com/cosmos/cosmos-sdk/archive/v$COSMOS_SDK_VERSION.zip"
unzip "$ZIP_FILE" "*.proto" -d "$COSMOS_DIR"
mv "$COSMOS_SDK_DIR-$COSMOS_SDK_VERSION" "$COSMOS_SDK_DIR"
rm "$ZIP_FILE"

# get osmosis proto files from repo
git clone https://github.com/osmosis-labs/osmosis.git

# Check if osmosis commit hash is provided and checkout to that commit
if [ $# -gt 0 ]; then
  OSMOSIS_COMMIT_HASH="$1"
  git -C osmosis checkout "$OSMOSIS_COMMIT_HASH"
fi

mv osmosis/proto/osmosis "$COSMOS_SDK_DIR/proto/osmosis"

# Extract the IBC Go version from the go.mod file
IBC_GO_VERSION=$(awk '/github.com\/cosmos\/ibc-go/ {print $2}' osmosis/go.mod)

# Clone IBC Go repository and checkout to the extracted version
git clone https://github.com/cosmos/ibc-go.git
git -C -q ibc-go checkout "$IBC_GO_VERSION"

# Move IBC Go proto files into the $COSMOS_SDK_DIR/proto directory
mv ibc-go/proto/* "$COSMOS_SDK_DIR/proto/"

# Extract the Wasmd version from the go.mod file
WASMD_VERSION=$(awk '/github.com\/osmosis-labs\/wasmd/ {print $2}' osmosis/go.mod)

# Clone Wasmd repository and checkout to the extracted version
git clone https://github.com/osmosislabs/wasmd.git
git -C -q wasmd checkout "$WASMD_VERSION"

# Move Wasmd proto files into the $COSMOS_SDK_DIR/proto directory
mv wasmd/proto/* "$COSMOS_SDK_DIR/proto/"

# Cleanup
rm -rf osmosis ibc-go wasmd
