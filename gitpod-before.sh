#! -- expected to be 'source'd
set -o pipefail

ccache --max-size 8GB

# changes that are made to files outside of /workspace are not persisted,
# and so must be done here as part of the 'before' hook
ln -s /workspace/datadir ~/.bitcoin
ln -s /workspace/bitpod/.bashrc ~/.bashrc.d/bitpod
ln -s /workspace/bitpod/.lcovrc ~/.lcovrc

source /workspace/bitpod/.bashrc