#! -- expected to be 'source'd

(set -eo pipefail

echo 🟢 Setting up default bitcoin core wallet
bitcoin-cli getwalletinfo 2> /dev/null || bitcoin-cli createwallet default
# Load the wallet by default on the next run (following a workspace restart)
sed -i 's/^#wallet=/wallet=/' /workspace/bitpod/bitcoin.conf

if [ "$(bitcoin-cli getblockcount)" = 0 ]; then
  echo 🟢 Mining some regtest blocks
  bitcoin-cli generatetoaddress 101 $(bitcoin-cli getnewaddress) > /dev/null
fi

echo 🟢 Bitcoin Core is ready

)