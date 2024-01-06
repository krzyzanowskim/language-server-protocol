#!/usr/bin/env bash

set -e
shopt -s extglob

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OUTPUT_DIR=$( mktemp -d )

pushd () {
	command pushd "$@" > /dev/null
}

popd () {
	command popd "$@" > /dev/null
}

CHECKOUT_DIR=$OUTPUT_DIR
git clone git@github.com:apple/sourcekit-lsp.git $CHECKOUT_DIR

pushd $CHECKOUT_DIR
# rm -rf -- !(.git)
cp -R $CHECKOUT_DIR/Sources/LanguageServerProtocol/* $SCRIPT_DIR/../Sources/LanguageServerProtocol
cp -R $CHECKOUT_DIR/Sources/LanguageServerProtocolJSONRPC/* $SCRIPT_DIR/../Sources/LanguageServerProtocolJSONRPC
cp -R $CHECKOUT_DIR/Sources/LSPTestSupport/* $SCRIPT_DIR/../Sources/LSPTestSupport
cp -R $CHECKOUT_DIR/Tests/LanguageServerProtocolJSONRPCTests/* $SCRIPT_DIR/../Tests/LanguageServerProtocolJSONRPCTests
cp -R $CHECKOUT_DIR/Tests/LanguageServerProtocolTests/* $SCRIPT_DIR/../Tests/LanguageServerProtocolTests
popd

rm -rf $CHECKOUT_DIR