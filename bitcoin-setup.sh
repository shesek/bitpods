#! -- expected to be 'source'd
set -eo pipefail

echo '🟢 setting up default bitcoin core wallet'
bitcoin-cli loadwallet default 2> /dev/null || bitcoin-cli createwallet default &&

if [ "$(bitcoin-cli getblockcount)" = 0 ]; then
  echo '🟢 mining some regtest blocks'
  bitcoin-cli generatetoaddress 101 $(bitcoin-cli getnewaddress) > /dev/null
fi
