#!/bin/bash
set -eox pipefail

# This script modifies the working directory to prepare a customized git branch
# for the given git submodule sources and configuration

# Options: WITH_GUI, BITCOIN_REPO_{URL,BRANCH} BTCDEB_REPO_{URL,BRANCH}

# Modify the .gitpod.yml base docker image to the gui variant and use 'bitcoin-qt' as the bitcoind command
if [ -n "$WITH_GUI" ]; then
  sed -i 's!shesek/bitpod:latest!shesek/bitpod:gui!' .gitpod.yml
  sed -i -r 's!^( *)bitcoind$!\1bitcoin-qt!' .gitpod.yml
fi

# Point the bitcoin git submodule to BITCOIN_REPO_URL#BITCOIN_REPO_BRANCH
[ -z "$BITCOIN_REPO_URL" ] || git submodule set-url -- bitcoin "$BITCOIN_REPO_URL"
: ${BITCOIN_REPO_BRANCH:=master}
(cd bitcoin && \
  git fetch origin "$BITCOIN_REPO_BRANCH" &&
  git reset --hard "origin/$BITCOIN_REPO_BRANCH")

[ -z "$BTCDEB_REPO_URL" ] || git submodule set-url -- btcdeb "$BTCDEB_REPO_URL"
: ${BTCDEB_REPO_BRANCH:=master}
(cd btcdeb && \
  git fetch origin "$BTCDEB_REPO_BRANCH" &&
  git reset --hard "origin/$BTCDEB_REPO_BRANCH")
