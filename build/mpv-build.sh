#!/bin/bash

# Note: Run this on MinGW64 after the successful building of ffmpeg.

cd /trunk/build

# Clone or enter the existing repository
if [ -d mpv-latest-git ]; then
    cd mpv-latest-git
    git pull
else
    git clone --branch release/0.39 https://github.com/mpv-player/mpv mpv-latest-git
    cd mpv-latest-git
fi

# Define cross-file.txt
cat <<EOF > cross-file.txt
[binaries]
c = 'x86_64-w64-mingw32-gcc'
cpp = 'x86_64-w64-mingw32-g++'
ar = 'ar'
windres = 'x86_64-w64-mingw32-windres'
strip = 'x86_64-w64-mingw32-strip'
exe_wrapper = 'wine64'

[host_machine]
system = 'windows'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF

# Setup mpv for compiling
# Note: Remove -Dc_args, the CUDA path parameters on the -Dc_link_args leaving -static only on c_link_args if
#       you don't have CUDA support enabled on ffmpeg
PKG_CONFIG="pkgconf --keep-system-libs --keep-system-cflags" \
    CC=${CC/ccache /} \
    CXX=${CXX/ccache /} \
    meson setup --default-library=static \
    --buildtype=release \
    -Dc_args="-I$(cygpath -sm "$CUDA_PATH")/include" \
    -Dc_link_args="-static -L$(cygpath -sm "$CUDA_PATH")/lib/x64" \
    -Dcpp_link_args="-static" \
    --prefix="/trunk/local64" \
    --bindir="/trunk/local64/bin-video" \
    -Dtests=false \
    -Dfuzzers=false \
    -Dpdf-build=disabled \
    -Dmanpage-build=disabled \
    -Dhtml-build=disabled \
    -Dd3d11=enabled \
    -Dlibmpv=true \
    --backend=ninja \
    --cross-file cross-file.txt build

# Compile mpv
meson compile -C build

# Install mpv
cd build
meson install
