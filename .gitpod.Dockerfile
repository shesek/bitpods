FROM gitpod/workspace-python:latest

SHELL ["/bin/bash", "-c"]

USER root

# C++ + Python specialized for Bitcoin Core development:
# From https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md and
# also https://github.com/bitcoin/bitcoin/blob/master/doc/dependencies.md

# Based on David Bakin's https://gitlab.com/bakins-bits/gitpod-setup-for-bitcoin-core-dev
# Thank you!

# Starting from PYTHON add LANG-C and BREW; result should be a much lighter C++ container than Gitpod's `workspace-full`


ARG DEBIAN_FRONTEND=noninteractive

RUN [ -f /usr/share/keyrings/llvm-archive-keyring.gpg ] || ( \
      curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | \
        sudo gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg \
      && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/focal/ \
               llvm-toolchain-focal main" | sudo tee /etc/apt/sources.list.d/llvm.list > /dev/null \
    ) \
    && apt update \
    && apt install -yq --no-install-recommends \
automake \
autotools-dev \
bsdmainutils \
build-essential \
clang \
clang-format \
clang-tidy \
clangd \
gdb \
keyboard-configuration \
lcov \
libboost-all-dev \
libboost-dev \
libevent-dev \
libminiupnpc-dev \
libnatpmp-dev \
libqrencode-dev \
libqt5core5a \
libqt5dbus5 \
libqt5gui5 \
libsqlite3-dev \
libtool \
libzmq3-dev \
lld \
llvm-15 \
pkg-config \
python3-zmq \
qttools5-dev \
qttools5-dev-tools \
qtwayland5 \
systemtap \
systemtap-sdt-dev

USER gitpod

RUN ([ -d /home/linuxbrew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

ENV CCACHE_DIR="/workspace/.ccache"
ENV PATH="/workspace/bin:/workspace/.pyenv:/workspace/.pyenv/bin:/workspace/.pyenv/shims:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/:${PATH}"
ENV MANPATH="${MANPATH}:/home/linuxbrew/.linuxbrew/share/man"
ENV INFOPATH="{$INFOPATH}:/home/linuxbrew/.linuxbrew/share/info"
ENV HOMEBREW_NO_AUTO_UPDATE=1

RUN    sudo apt remove -y cmake \
    && brew install cmake       \
    && brew install ccache      \
    && brew install bear        \
    && sudo apt-get clean -y    \
    && sudo rm -rf /var/cache/debconf/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the Python version used by Bitcoin Core
# This is the version that Core uses at the time of writing. If it changes, the new
# version (indicated via Core's .python-version file) will be installed too during
# the Gitpod init stage. Installing early here is done to achieve faster init times.
RUN pyenv install -s -v 3.6.12

# Python is initially installed to /home/gitpod/.pyenv because /workspace gets reset by Gitpod before
# the prebuild stage, but the files are moved to /workspace/.pyenv in the Gitpod init stage so that
# additional Python versions installed in the workspace gets persisted.
ENV PYENV_ROOT="/workspace/.pyenv"

# Leaving out precise BDB version - must build with --with-incompatible-bdb or --without-bdb
# Leaving out lldb-15 & python3-lldb-15 - suddenly including lldb-15 causes clang/clang++ to segfault

# The explicit install of keyboard-configuration is because it is required by something or
# other in the QT set but it demands (stupidly!) to ask the user _which_ keyboard layout to
# install, which breaks the docker build.  So you have to explicitly install it in a mode
# where you tell it to shut up. (via 'noninteractive')

# Consider adding gitpod's vnc to get X server + VNC GUI remoting for GUI work
