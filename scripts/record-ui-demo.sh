#!/usr/bin/env bash
# Records a scripted walkthrough of the UI and checks that every feature
# reacts. Runs headless on a virtual X display, so it works in CI and on any
# Linux machine.
#
# Usage:  scripts/record-ui-demo.sh <path/to/TestPrototype> [output-dir]
#
# Output (default ./ui-demo):
#   ui-demo.gif   README animation (960 px wide)
#   ui-demo.mp4   full-size video with captions and tap markers
#   results.md    one line per step: passed / failed / warning
#   app.log       the app's console output
# Exit code is non-zero if a required step failed or the app crashed.
#
# Needs: Xvfb, xdotool, ffmpeg, jq, libxcb-cursor0 (Qt >= 6.5 on X11),
#        optionally fonts-dejavu-core (captions).
#
# ---------------------------------------------------------------------------
# Adding a new feature to the demo: add lines to scenario() below.
#   step "<caption>" <check> <element> <action...>
#     <check>    required  - the step fails if <element> does not change
#                optional  - only a warning (use for network-dependent things)
#     <element>  objectName path from the app, e.g. driverHVAC  (the region
#                that must change on screen after the action); append
#                @top,right,bottom,left to ignore a border, e.g. map@130,0,30,0
#   actions:  click <element> [times]   type "<text>"   key <keysym>
#             drag <element> <dx> <dy>  scroll <element> up|down <n>
#   pause <seconds>    caption "<text>" <seconds>
# Elements are found by objectName (see UI_LOCATOR_FILE in Testing/uilocator.h).
# Run the app with UI_LOCATOR_FILE=/tmp/ui.json to list all available names.
#
# Coverage: at the end the script lists every interactive element of the app
# that no step used, and clickable elements without an objectName. These are
# warnings; set DEMO_REQUIRE_COVERAGE=1 to make them fail the run.
# ---------------------------------------------------------------------------

scenario() {
    caption "Infotainment Prototype" 3

    step "Unlock the car"            required lockIcon       click lockIcon
    step "Lock the car"              required lockIcon       click lockIcon

    
    step "Car view: left side"       required leftCarImage   click carView.left
    step "Car view: right side"      required leftCarImage   click carView.right

    step "Open the frunk"            required leftCarImage   click frunkHotspot
    step "Open the trunk"            required leftCarImage   click trunkHotspot
    step "Close the frunk"           required leftCarImage   click frunkHotspot
    step "Close the trunk"           required leftCarImage   click trunkHotspot
    step "Start charging"            required chargePortButton click chargePortButton
    step "Stop charging"             required chargePortButton click chargePortButton
    # The top bar lock must follow the lock on the car view.
    step "Unlock from the car view"  required lockIcon       click carLockButton
    step "Lock from the car view"    required lockIcon       click carLockButton

    step "Car view: front"           required leftCarImage   click carView.front

    step "Driver temperature up"     required driverHVAC     click driverHVAC.up 3
    step "Driver temperature down"   required driverHVAC     click driverHVAC.down 2
    step "Passenger temperature up"  required passengerHVAC  click passengerHVAC.up 2
    step "Passenger temperature down" required passengerHVAC click passengerHVAC.down 3

    step "Volume up"                 required volume         click volume.up 5
    pause 1.2
    step "Volume down"               required volume         click volume.down 8
    pause 1.2

    # Map tour: three places, zooming in and out between them. Optional,
    # because tiles and place search come from OpenStreetMap over the internet.
    step "Find Marienplatz"          optional map@130,0,30,0 search "Marienplatz, Munich"
    step "Zoom in"                   optional map@130,0,30,0 scroll map up 2
    step "Zoom out to the city"      optional map@130,0,30,0 scroll map down 4
    step "Find Olympiapark"          optional map@130,0,30,0 search "Olympiapark, Munich"
    step "Zoom in"                   optional map@130,0,30,0 scroll map up 1
    step "Find Allianz Arena"        optional map@130,0,30,0 search "Allianz Arena, Munich"
    step "Pan the map"               optional map@130,0,30,0 drag map -220 100
    step "Zoom out"                  optional map@130,0,30,0 scroll map down 3

    caption "Infotainment Prototype" 2
}

# ---------------------------------------------------------------------------
set -uo pipefail

APP=${1:?usage: $0 <path/to/TestPrototype> [output-dir]}
OUT=${2:-ui-demo}
FPS=${DEMO_FPS:-15}
GIF_WIDTH=${DEMO_GIF_WIDTH:-960}
GIF_FPS=${DEMO_GIF_FPS:-10}
W=1280 H=720
FONT=${DEMO_FONT:-/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf}

APP=$(realpath "$APP")
mkdir -p "$OUT"; OUT=$(realpath "$OUT")
WORK=$(mktemp -d)
LOC="$WORK/locations.json"
EVENTS="$WORK/events.txt"     # "tap <t> <x> <y>" and "caption <t0> <t1> <file>"
RESULTS="$OUT/results.md"
: > "$EVENTS"
printf '| Step | Result |\n|---|---|\n' > "$RESULTS"
FAILED=0

log() { echo "[demo] $*"; }

# ---- virtual display ------------------------------------------------------
for n in $(seq 90 110); do [ -e "/tmp/.X11-unix/X$n" ] || { DISPLAY_NUM=$n; break; }; done
export DISPLAY=":$DISPLAY_NUM"
Xvfb "$DISPLAY" -screen 0 "${W}x${H}x24" -nolisten tcp >/dev/null 2>&1 &
XVFB_PID=$!
# shellcheck disable=SC2317  # called through the EXIT trap
cleanup() {
    kill "${FFMPEG_PID:-}" "${APP_PID:-}" 2>/dev/null
    kill "$XVFB_PID" 2>/dev/null
    rm -rf "$WORK"
}
trap cleanup EXIT
for _ in $(seq 50); do xdotool getmouselocation >/dev/null 2>&1 && break; sleep 0.1; done

# ---- start the app ----------------------------------------------------------
log "Starting $APP on $DISPLAY"
UI_LOCATOR_FILE="$LOC" QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1 \
    "$APP" > "$OUT/app.log" 2>&1 &
APP_PID=$!
for _ in $(seq 300); do [ -s "$LOC" ] && break; sleep 0.1; done
if [ ! -s "$LOC" ]; then
    log "App did not show its window within 30 s"; cat "$OUT/app.log"; exit 1
fi
sleep 1   # let the first layout settle and map tiles start loading
xdotool mousemove $((W / 2)) $((H / 2))

# ---- helpers ------------------------------------------------------------------
USED="$WORK/used.txt"; : > "$USED"     # elements the scenario interacted with
use() { echo "${1%%@*}" >> "$USED"; }
now() { date +%s.%N; }
elapsed() { awk -v a="$T0" -v b="$(now)" 'BEGIN { printf "%.2f", b - a }'; }

# rect <element>[@top,right,bottom,left]  ->  sets X Y RW RH (screen coordinates)
# The optional insets shrink the region, e.g. map@130,0,30,0 skips the
# search box and clock drawn on top of the map.
rect() {
    local name=${1%%@*} insets=0,0,0,0 r it ir ib il
    [[ $1 == *@* ]] && insets=${1#*@}
    r=$(jq -r --arg k "$name" '.[$k] | select(.) | "\(.x) \(.y) \(.w) \(.h)"' "$LOC")
    [ -n "$r" ] || { log "Element '$name' not found (is its objectName set?)"; return 1; }
    read -r X Y RW RH <<< "$r"
    IFS=, read -r it ir ib il <<< "$insets"
    X=$((X + il)); Y=$((Y + it)); RW=$((RW - il - ir)); RH=$((RH - it - ib))
}
center() { rect "$1" || return 1; CX=$((X + RW / 2)); CY=$((Y + RH / 2)); }

# Fingerprint of a screen region (without the mouse pointer); changes whenever
# any pixel of the UI in it changes.
region_hash() {
    rect "$1" || return 1
    ffmpeg -loglevel error -f x11grab -draw_mouse 0 -video_size "${RW}x${RH}" -i "$DISPLAY+$X,$Y" \
        -frames:v 1 -f rawvideo -pix_fmt rgb24 - | md5sum | cut -d' ' -f1
}

glide() {   # move the pointer smoothly so viewers can follow it
    local tx=$1 ty=$2 sx sy i
    eval "$(xdotool getmouselocation --shell | grep -E '^(X|Y)=' | sed 's/^/S/')"
    sx=$SX sy=$SY
    for i in 1 2 3 4 5 6 7 8; do
        xdotool mousemove $((sx + (tx - sx) * i / 8)) $((sy + (ty - sy) * i / 8))
        sleep 0.03
    done
}

do_click() {
    local times=${2:-1} i
    use "$1"
    center "$1" || return 1
    glide "$CX" "$CY"
    for ((i = 0; i < times; i++)); do
        echo "tap $(elapsed) $CX $CY" >> "$EVENTS"
        xdotool click 1
        sleep 0.35
        # Also look right after the first click: some feedback is temporary
        # (the volume number is replaced by the icon again after 1 s).
        if [ "$i" -eq 0 ] && [ -n "${CHECK_REGION:-}" ]; then
            MID_HASH=$(region_hash "$CHECK_REGION")
        fi
    done
}

do_search() {
    local base i
    do_click navSearch.input || return 1
    xdotool type --delay 80 "$1"
    sleep 0.3
    base=$(region_hash "${CHECK_REGION:-map}")
    xdotool key Return
    # Place search goes over the network: wait until the map moves (max 8 s),
    # then give the new tiles time to load.
    for i in $(seq 16); do
        sleep 0.5
        [ "$(region_hash "${CHECK_REGION:-map}")" != "$base" ] && break
    done
    if [ "$i" -lt 16 ]; then sleep 2; fi   # no move: the step check reports it
}

do_drag() {
    local dx=$2 dy=$3 i
    use "$1"
    center "$1" || return 1
    glide "$CX" "$CY"
    echo "tap $(elapsed) $CX $CY" >> "$EVENTS"
    xdotool mousedown 1
    for i in $(seq 1 15); do
        xdotool mousemove $((CX + dx * i / 15)) $((CY + dy * i / 15)); sleep 0.04
    done
    xdotool mouseup 1
    sleep 1.5   # tiles for the new area
}

do_scroll() {
    local button=4 i
    [ "$2" = down ] && button=5
    use "$1"
    center "$1" || return 1
    glide "$CX" "$CY"
    # One zoom level per wheel step, slow enough to see each level load.
    for ((i = 0; i < $3; i++)); do xdotool click "$button"; sleep 0.7; done
    sleep 1.2
}

run_action() {
    local a=$1; shift
    case $a in
        click)  do_click "$@" ;;
        search) do_search "$@" ;;
        drag)   do_drag "$@" ;;
        scroll) do_scroll "$@" ;;
        type)   xdotool type --delay 80 "$1" ;;
        key)    xdotool key "$1" ;;
        *) log "Unknown action '$a'"; return 1 ;;
    esac
}

caption_file() { local f; f=$(mktemp -p "$WORK" cap.XXXX); printf '%s' "$1" > "$f"; echo "$f"; }

caption() {
    local t0 f; t0=$(elapsed); f=$(caption_file "$1")
    sleep "$2"
    echo "caption $t0 $(elapsed) $f" >> "$EVENTS"
}

pause() { sleep "$1"; }

step() {
    local name=$1 check=$2 element=$3; shift 3
    local t0 f before after result
    t0=$(elapsed); f=$(caption_file "$name")
    CHECK_REGION=$element MID_HASH=''

    if ! kill -0 "$APP_PID" 2>/dev/null; then
        result="❌ app is not running"; FAILED=1
    else
        before=$(region_hash "$element")
        run_action "$@"; local rc=$?
        sleep 0.5
        after=$(region_hash "$element")
        if [ $rc -ne 0 ] || [ -z "$before" ]; then
            result="❌ could not run (element missing?)"; [ "$check" = required ] && FAILED=1
        elif [ "$before" != "$after" ] || { [ -n "$MID_HASH" ] && [ "$before" != "$MID_HASH" ]; }; then
            result="✅ passed"
        elif [ "$check" = required ]; then
            result="❌ no change on screen"; FAILED=1
        else
            result="⚠️ no change on screen (optional, e.g. no network)"
        fi
    fi
    CHECK_REGION='' MID_HASH=''
    echo "caption $t0 $(elapsed) $f" >> "$EVENTS"
    log "$name: $result"
    printf '| %s | %s |\n' "$name" "$result" >> "$RESULTS"
}

# ---- record -----------------------------------------------------------------
RAW="$WORK/raw.mp4"
T0=$(now)
ffmpeg -loglevel error -y -f x11grab -draw_mouse 1 -framerate "$FPS" \
    -video_size "${W}x${H}" -i "$DISPLAY" \
    -c:v libx264 -preset ultrafast -crf 16 -pix_fmt yuv420p "$RAW" &
FFMPEG_PID=$!
sleep 0.5

scenario

kill -INT "$FFMPEG_PID"; wait "$FFMPEG_PID" 2>/dev/null; FFMPEG_PID=

# ---- coverage: interactive elements no step used --------------------------------
UNCOVERED=$(jq -r 'to_entries[] | select(.value.interactive) | .key' "$LOC" | sed 's/#[0-9]*$//' | sort -u \
            | grep -vxF -f <(sort -u "$USED") || true)
TOTAL=$(jq '[.[] | select(.interactive)] | length' "$LOC")
{
    printf '\n**Coverage:** '
    if [ -z "$UNCOVERED" ]; then
        printf 'all %s interactive elements are used by the demo ✅\n' "$TOTAL"
    else
        printf '⚠️ not tested by the demo yet (add a step in scripts/record-ui-demo.sh):\n\n'
        while read -r e; do
            # shellcheck disable=SC2016  # backticks are Markdown here
            case $e in
                "(unnamed"*) printf -- '- `%s`: give it an `objectName` first\n' "$e" ;;
                *)           printf -- '- `%s`\n' "$e" ;;
            esac
        done <<< "$UNCOVERED"
    fi
} >> "$RESULTS"
if [ -n "$UNCOVERED" ]; then
    log "Not covered by the demo: $(echo "$UNCOVERED" | paste -sd, -)"
    [ -n "${GITHUB_ACTIONS:-}" ] && echo "::warning title=UI demo coverage::Not tested by the demo yet: $(echo "$UNCOVERED" | paste -sd, - | sed 's/,/, /g')"
    [ "${DEMO_REQUIRE_COVERAGE:-0}" = 1 ] && FAILED=1
fi
if kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID"
else
    log "The app exited during the demo"; FAILED=1
    printf '| %s | %s |\n' "App still running at the end" "❌ crashed or exited" >> "$RESULTS"
fi
wait "$APP_PID" 2>/dev/null; APP_PID=

# ---- annotate: captions and tap markers ---------------------------------------
FILTER="null"
while read -r kind a b c; do
    case $kind in
        tap)
            FILTER+=",drawbox=x=$((b - 20)):y=$((c - 20)):w=40:h=40:color=red@0.8:t=4"
            FILTER+=":enable='between(t,$a,$a+0.4)'" ;;
        caption)
            [ -f "$FONT" ] || continue
            FILTER+=",drawtext=fontfile=$FONT:textfile=$c:fontsize=24:fontcolor=white"
            FILTER+=":box=1:boxcolor=black@0.65:boxborderw=12"
            FILTER+=":x=853-text_w/2:y=600:enable='between(t,$a,$b)'" ;;
    esac
done < "$EVENTS"
[ -f "$FONT" ] || log "Font $FONT not found, captions skipped"

log "Rendering video"
ffmpeg -loglevel error -y -i "$RAW" -vf "$FILTER" \
    -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p -movflags +faststart \
    "$OUT/ui-demo.mp4" || { log "Rendering failed"; exit 1; }

log "Rendering GIF"
ffmpeg -loglevel error -y -i "$OUT/ui-demo.mp4" -filter_complex \
    "fps=$GIF_FPS,scale=$GIF_WIDTH:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
    "$OUT/ui-demo.gif" || { log "GIF rendering failed"; exit 1; }

log "Done: $(du -h "$OUT/ui-demo.gif" | cut -f1) GIF, $(du -h "$OUT/ui-demo.mp4" | cut -f1) MP4 in $OUT"
cat "$RESULTS"
exit "$FAILED"
