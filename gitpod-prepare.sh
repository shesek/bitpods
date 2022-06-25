#!/bin/bash
set -eo pipefail

# This script modifies the working directory to prepare a customized git branch
# for the given git submodule sources and configuration

# Options: WITH_GUI, BITCOIN_REPO_{URL,BRANCH} BTCDEB_REPO_{URL,BRANCH}

: ${BITCOIN_REPO_URL:?missing BITCOIN_REPO_URL}
: ${BITCOIN_REPO_BRANCH:?missing BITCOIN_REPO_BRANCH}

: ${BTCDEB_REPO_URL:=https://github.com/bitcoin-core/btcdeb}
: ${BTCDEB_REPO_BRANCH:=master}

[ -n "$VERBOSE" ] && set -x

# Modify the .gitpod.yml base docker image to support QT GUI
if [ -n "$WITH_GUI" ]; then
  echo 🟢 QT GUI mode is enabled
  # Update the base docker image
  sed -i 's!shesek/bitpod:latest!shesek/bitpod:gui!' .gitpod.yml
  # Run bitcoin-qt instead of bitcoind
  sed -i -r 's!^( *)bitcoind( \$BITCOIN_OPT)!\1bitcoin-qt\2!' .gitpod.yml
  # Change the block explorer port (3002) onOpen to 'notify' instead of 'open-preview'
  # This is necessary because multiple ports with 'open-preview' conflict with each other.
  # See https://discord.com/channels/816244985187008514/816246578594840586/989033704351494194
  sed -i "/'notify' in gui mode/s/open-preview/notify/" .gitpod.yml
fi



# Update the bitcoin and btcpdeb submodules

echo 🟢 Checking for bitcoin git submodule updates

git submodule set-url bitcoin "$BITCOIN_REPO_URL"
git submodule set-branch --branch "$BITCOIN_REPO_BRANCH" bitcoin

# If the commit hash for the branch is known, we can update straight to it without
# fetching the remote using `git update-index`. https://stackoverflow.com/q/22764951
if [ -n "$BITCOIN_REPO_COMMIT" ]; then
  current_commit=$(git submodule status bitcoin | sed 's/^[-+ ]//' | cut -d' ' -f1)

  if [ "$current_commit" != "$BITCOIN_REPO_COMMIT" ]; then
    echo "Updating bitcoin submodule to commit $BITCOIN_REPO_COMMIT"

    # the submodule must not be checked out for update-index to work
    git submodule deinit bitcoin &> /dev/null || true

    git update-index --cacheinfo "160000,$BITCOIN_REPO_COMMIT,bitcoin"
  fi

# Otherwise, update by fetching the branch from the remote
else

  # Use a local --reference repo to speed things up
  localref() {
    [ -n "$PODS_BASEGIT" ] && echo "--reference $PODS_BASEGIT/$1"
  }

  git submodule update --init --remote --force $(localref bitcoin) bitcoin
fi

#git submodule set-url btcdeb "$BTCDEB_REPO_URL"
#git submodule set-branch --branch "$BTCDEB_REPO_BRANCH" btcdeb
#git submodule update --init --remote --force $(localref btcdeb) btcdeb