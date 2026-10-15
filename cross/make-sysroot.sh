#!/usr/bin/env bash
# Build the sysroot (the target's headers + libraries) that the cross
# toolchain links against. Two sources are supported:
#
#   1) A running board (real Pi or the QEMU virtual board) over SSH:
#        cross/make-sysroot.sh ssh pi@raspberrypi.local [port]
#
#   2) A Raspberry Pi OS image file, no hardware needed:
#        cross/make-sysroot.sh image 2025-xx-xx-raspios-trixie-arm64.img
#      (installing the -dev packages into an image needs qemu-user-static:
#       sudo apt install qemu-user-static binfmt-support)
#
# Output: $RPI_SYSROOT (default ~/rpi-sysroot)
set -euo pipefail

SYSROOT=${RPI_SYSROOT:-$HOME/rpi-sysroot}
DEV_PACKAGES="qt6-base-dev qt6-declarative-dev libgl-dev libegl-dev libgles-dev \
  libxkbcommon-dev libfontconfig-dev libfreetype-dev libglib2.0-dev libdbus-1-dev"

copy_tree() {   # $1 = rsync source prefix (user@host: or local path), rest = extra rsync args
    local src=$1; shift
    for d in lib usr/include usr/lib usr/share/pkgconfig; do
        mkdir -p "$SYSROOT/$d"
        ${RSYNC:-rsync} -a --delete "$@" "$src/$d/" "$SYSROOT/$d/"
    done
}

fix_links() {   # turn absolute symlinks into sysroot-relative ones
    command -v symlinks >/dev/null || { echo "install 'symlinks' (sudo apt install symlinks)"; exit 1; }
    symlinks -rc "$SYSROOT" >/dev/null
}

case "${1:-}" in
  ssh)
    TARGET=${2:?user@host}; PORT=${3:-22}
    echo "==> Installing development packages on $TARGET"
    ssh -p "$PORT" "$TARGET" "sudo apt-get update -qq && sudo apt-get install -y -qq $DEV_PACKAGES"
    echo "==> Copying into $SYSROOT"
    copy_tree "$TARGET:" -z -e "ssh -p $PORT" --rsync-path="sudo rsync"
    ;;
  image)
    IMG=${2:?path to .img}
    MNT=$(mktemp -d)
    LOOP=$(sudo losetup -fP --show "$IMG")
    trap 'sudo umount -R "$MNT" 2>/dev/null || true; sudo losetup -d "$LOOP"; rmdir "$MNT"' EXIT
    sudo mount "${LOOP}p2" "$MNT"
    echo "==> Installing development packages inside the image (via qemu-user)"
    for fs in proc sys dev; do sudo mount --bind /$fs "$MNT/$fs"; done
    sudo cp --remove-destination /etc/resolv.conf "$MNT/etc/resolv.conf"   # never write through a symlink to the host
    sudo chroot "$MNT" /bin/bash -c "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $DEV_PACKAGES"
    echo "==> Copying into $SYSROOT"
    RSYNC="sudo rsync" copy_tree "$MNT"
    sudo chown -R "$(id -u):$(id -g)" "$SYSROOT"
    ;;
  *)
    sed -n '2,15p' "$0"; exit 1 ;;
esac

fix_links
echo "==> Sysroot ready: $SYSROOT"
qtcore=$(find "$SYSROOT/usr/lib/aarch64-linux-gnu" -maxdepth 1 -name 'libQt6Core.so.6.*' | head -1)
echo "    Target Qt: ${qtcore##*.so.}  (install the same 6.x on the host for QT_HOST_PATH)"
