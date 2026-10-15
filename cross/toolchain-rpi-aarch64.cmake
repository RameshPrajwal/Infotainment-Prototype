# CMake toolchain file: cross-compile for Raspberry Pi OS Trixie (64-bit)
# from an x86_64 Linux host, using the Pi's own Qt 6 from a sysroot.
#
# Needs:
#   - aarch64-linux-gnu-gcc / g++   (sudo apt install g++-aarch64-linux-gnu)
#   - a sysroot made by cross/make-sysroot.sh       (default: ~/rpi-sysroot)
#   - a host (desktop) Qt of the SAME minor version as the Pi's Qt
#     (Pi OS Trixie ships Qt 6.8 -> install Qt 6.8.x "Desktop gcc 64-bit"
#      with the Qt Online Installer), passed as QT_HOST_PATH
#
# Example:
#   cmake -S . -B build-rpi -G Ninja \
#     -DCMAKE_TOOLCHAIN_FILE=cross/toolchain-rpi-aarch64.cmake \
#     -DQT_HOST_PATH=$HOME/Qt/6.8.3/gcc_64

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_LIBRARY_ARCHITECTURE aarch64-linux-gnu)

if(NOT DEFINED RPI_SYSROOT)
    if(DEFINED ENV{RPI_SYSROOT})
        set(RPI_SYSROOT "$ENV{RPI_SYSROOT}")
    else()
        set(RPI_SYSROOT "$ENV{HOME}/rpi-sysroot")
    endif()
endif()
set(CMAKE_SYSROOT "${RPI_SYSROOT}")

set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Look for libraries/headers/CMake packages only in the sysroot,
# but run programs (moc, rcc, ...) from the host.
set(CMAKE_FIND_ROOT_PATH "${RPI_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR}
    "${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${RPI_SYSROOT}/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${RPI_SYSROOT}")

# Pi 4 and Pi 5 are both ARMv8-A
set(CMAKE_C_FLAGS_INIT   "-march=armv8-a")
set(CMAKE_CXX_FLAGS_INIT "-march=armv8-a")

# Debian keeps some libraries' dependencies in the sysroot's multiarch dir;
# point the linker there so indirect dependencies resolve.
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "-Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${RPI_SYSROOT}/lib/aarch64-linux-gnu")
