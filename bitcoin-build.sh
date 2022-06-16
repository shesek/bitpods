#!/bin/bash
set -eo pipefail
set -x

# Based on David Bakin's https://gitlab.com/bakins-bits/gitpod-setup-for-bitcoin-core-dev
# Thank you!

OPTIONS_FOR_GCC=""
OPTIONS_FOR_CLANG="CXX=clang++ CC=clang"

OPTIONS_FOR_DEBUG="--enable-debug --disable-hardening --disable-bench --disable-fuzz --disable-fuzz-binary --enable-usdt --enable-threadlocal"
OPTIONS_FOR_RELEASE=""
OPTIONS_FOR_RELEASE_WITH_SYMBOLS="--enable-debug"  # don't know if this works: might disable optimizations too

OPTIONS_FOR_GUI="-with-gui-qt5 --enable-gui-tests --with-qtdbus --with-qrencode"
OPTIONS_FOR_NO_GUI="--without-gui --disable-gui-tests"

OPTIONS_FOR_COVERAGE="--enable-lcov --enable-lcov-branch-coverage"

# Custom user options
USE_ADDITIONAL_OPTIONS=

# Uses clang by default, unless GCC is set
COMPILER_IS=$([ -n "$GCC" ] && echo gcc || echo clang)
USE_COMPILER=$([ $COMPILER_IS = clang ] && echo "$OPTIONS_FOR_CLANG" || echo "$OPTIONS_FOR_GCC")

# Defaults to debug build, unless BUILD_RELEASE is set
USE_BUILD_TYPE="$([ -n "$BUILD_RELEASE" ] && echo "$OPTIONS_FOR_RELEASE" || echo "$OPTIONS_FOR_DEBUG")
                $([ -n "$RELEASE_WITH_SYMBOLS" ] && echo "$OPTIONS_FOR_RELEASE_WITH_SYMBOLS" || echo)"

# QT GUI is disabled by default, unless WITH_GUI is set
USE_GUI=$([ -n "$WITH_GUI" ] && echo "$OPTIONS_FOR_GUI" || echo "$OPTIONS_FOR_NO_GUI")

# Coverage is disabled by default, unless WITH_COVERAGE is set
USE_COVERAGE=$([ -n "$WITH_COVERAGE" ] && echo "$OPTIONS_FOR_COVERAGE" || echo)

# Compile with bear when using clang
BEAR=$([ $COMPILER_IS = clang ] && echo "bear --" || echo)

ccache --max-size 8GB

# Build
echo '🟢 building bitcoin'
pushd /workspace/bitcoin

./autogen.sh

./configure $USE_COMPILER $USE_BUILD_TYPE $USE_GUI $USE_COVERAGE \
            --with-boost=yes --with-utils --with-libs --with-daemon \
            --with-sqlite=yes --without-bdb --disable-man \
            $USE_ADDITIONAL_OPTIONS \
            --disable-silent-rules

make clean
$BEAR make -j$(nproc)

if [ -z "$NO_CHECK" ]; then
  echo '🟢 checking bitcoin'
  make -j$(nproc) check
fi

if [ -n "$WITH_COVERAGE" ]; then
  cleancov
  make -j$(nproc) test_bitcoin.coverage/.dirstamp
fi

popd