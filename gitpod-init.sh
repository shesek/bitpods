#! -- expected to be 'source'd

(set -eo pipefail

echo '🟢 running gitpod-init.sh'

mkdir -p /workspace/{bin,datadir}

ln -s /workspace/bitpod/bitcoin.conf /workspace/datadir/

# Symlink git submodules to be available directly under /workspace
ln -s /workspace/bitpod/{bitcoin,btcdeb,btc-rpc-explorer} /workspace

# Make bitpod available within the bitcoin core directory, so its easily accessible in the editor
ln -s /workspace/bitpod /workspace/bitcoin/.bitpod

ln -s /workspace/bitcoin/src/bitcoin{d,-cli,-tx,-util,-wallet} /workspace/bin/
if [ -n "$WITH_GUI" ]; then
  ln -s /workspace/bitcoin/src/qt/bitcoin-qt /workspace/bin/
fi

ln -s /workspace/bitpod/bitcoin-build.sh /workspace/bin/bitcoin-build
ln -s $(which llvm-cov-15) /workspace/bin/llvm-cov
#hash -r

# Bitcoin Core's Python version will typically already be installed by the Dockerfile, but it is
# re-installed here in case the .python-version for the particular branch uses a different version
pyenv install -s -v $(cat /workspace/bitcoin/.python-version)
pyenv versions

(cd /workspace/bitcoin &&
  git remote add upstream https://github.com/bitcoin/bitcoin)
(cd /workspace/bitpod/.git/modules/bitcoin &&
  rm info/exclude && ln -s /workspace/bitpod/.gitignore.global info/exclude)

[ -n "$NO_BUILD" ] || bitcoin-build
[ -z "$BTCDEB" ] || btcdeb-build

)