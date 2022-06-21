#alias cleancov="rm -f test_bitcoin.coverage/.dirstamp && find ${BITCOIN_ROOT} -name '*.gcda' | xargs -r rm"
#alias makecov="rm -f test_bitcoin.coverage/.dirstamp && make -j cov"
#alias maketcov="rm -f test_bitcoin.coverage/.dirstamp && make -j test_bitcoin.coverage/.dirstamp"

alias btc=bitcoin-cli

alias bitcoin-check="make -C /workspace/bitcoin -j$(nproc) check"

alias bitcoin-test="/workspace/bitcoin/test/functional/test_runner.py"