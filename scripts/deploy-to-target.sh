#!/usr/bin/env bash
# Copy an arm64 build to a board (real Raspberry Pi or the QEMU virtual board)
# and start it.
#
# Usage:
#   scripts/deploy-to-target.sh <binary> <user@host> [ssh-port] [--service]
#
# Examples:
#   scripts/deploy-to-target.sh build-rpi/TestPrototype pi@raspberrypi.local
#   scripts/deploy-to-target.sh TestPrototype pi@localhost 2222
#   scripts/deploy-to-target.sh TestPrototype pi@raspberrypi.local 22 --service
set -euo pipefail

BIN=${1:?path to the arm64 TestPrototype binary}
TARGET=${2:?user@host of the board}
PORT=${3:-22}
MODE=${4:-run}
HERE=$(cd "$(dirname "$0")" && pwd)
SSH="ssh -p $PORT"
DEST=/opt/TestPrototype/bin

if ! file "$BIN" | grep -q "ARM aarch64"; then
    echo "error: $BIN is not an arm64 binary" >&2; exit 1
fi

echo "==> Installing Qt runtime packages on $TARGET"
$SSH "$TARGET" "sudo apt-get update -qq && sudo apt-get install -y -qq $(tr '\n' ' ' < "$HERE/target-runtime-packages.txt")"

echo "==> Copying binary to $DEST"
$SSH "$TARGET" "sudo mkdir -p $DEST && sudo chown \$(id -u):\$(id -g) $DEST"
rsync -az -e "$SSH" "$BIN" "$TARGET:$DEST/TestPrototype"

if [ "$MODE" = "--service" ]; then
    echo "==> Installing systemd service (starts at boot)"
    rsync -az -e "$SSH" "$HERE/../deploy/infotainment.service" "$TARGET:/tmp/"
    $SSH "$TARGET" "sudo mv /tmp/infotainment.service /etc/systemd/system/ && \
                    sudo systemctl daemon-reload && sudo systemctl enable --now infotainment && \
                    systemctl --no-pager status infotainment | head -5"
else
    echo "==> Starting app (Ctrl+C to stop). Uses the desktop session if one is running."
    $SSH -t "$TARGET" "export XDG_RUNTIME_DIR=/run/user/\$(id -u); \
        if [ -S \$XDG_RUNTIME_DIR/wayland-0 ]; then export WAYLAND_DISPLAY=wayland-0 QT_QPA_PLATFORM=wayland; \
        else export QT_QPA_PLATFORM=\${QT_QPA_PLATFORM:-eglfs}; fi; \
        $DEST/TestPrototype"
fi
