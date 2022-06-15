#! -- expected to be 'source'd

ccache --max-size 8GB

ln -s /workspace/datadir ~/.bitcoin
ln -s /workspace/bitpod/.bashrc ~/.bashrc.d/bitpod
ln -s /workspace/bitpod/.lcovrc ~/.lcovrc

source /workspace/bitpod/.bashrc

cd /workspace/bitcoin