#!/bin/bash
set -eox pipefail

# This script modifies the working directory to prepare a customized git branch
# for the given git submodule sources and configuration

# Options: WITH_GUI, BITCOIN_REPO_{URL,BRANCH} BTCDEB_REPO_{URL,BRANCH}

: ${BITCOIN_REPO_URL:?missing BITCOIN_REPO_URL}
: ${BITCOIN_REPO_BRANCH:?missing BITCOIN_REPO_BRANCH}

: ${BTCDEB_REPO_URL:=https://github.com/bitcoin-core/btcdeb}
: ${BTCDEB_REPO_BRANCH:=master}

# Modify the .gitpod.yml base docker image to the gui variant and use 'bitcoin-qt' as the bitcoind command
if [ -n "$WITH_GUI" ]; then
  sed -i 's!shesek/bitpod:latest!shesek/bitpod:gui!' .gitpod.yml
  sed -i -r 's!^( *)bitcoind$!\1bitcoin-qt!' .gitpod.yml
fi

# Update the bitcoin and btcpdeb submodules

git submodule set-url bitcoin "$BITCOIN_REPO_URL"
git submodule set-branch --branch "$BITCOIN_REPO_BRANCH" bitcoin
git submodule update --init --remote --depth 1 bitcoin

git submodule set-url btcdeb "$BTCDEB_REPO_URL"
git submodule set-branch --branch "$BTCDEB_REPO_BRANCH" btcdeb
git submodule update --init --remote --depth 1 btcdeb