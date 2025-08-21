#!/bin/bash

########## EDIT THESE PLACEHOLDERS ##########
# Path to FlightGear executable (AppImage or system 'fgfs')
FG_APP="${FG_APP:-./FlightGear-2020.3.19-x86_64.AppImage}"   # e.g., /home/you/Downloads/FlightGear-2020.3.19-x86_64.AppImage
# Path to fgdata directory
FG_ROOT="${FG_ROOT:-/path/to/Flightgear/fgdata}"              # e.g., /home/you/Documents/Flightgear/fgdata

FG_AIRCRAFT="${FG_AIRCRAFT:-c172p}"

FG_FDM_HOST="${FG_FDM_HOST:-localhost}"
FG_FDM_IN="${FG_FDM_IN:-5501}"
FG_FDM_OUT="${FG_FDM_OUT:-5502}"
FG_FDM_DATA="${FG_FDM_DATA:-5503}"

FG_MP_HOST_IN="${FG_MP_HOST_IN:-localhost}"
FG_MP_HOST_OUT="${FG_MP_HOST_OUT:-localhost}"
FG_MP_IN_PORT="${FG_MP_IN_PORT:-5701}"
FG_MP_OUT_PORT="${FG_MP_OUT_PORT:-5702}"

FG_START_DATE="${FG_START_DATE:-2004:06:01:09:00:00}"
FG_AIRPORT="${FG_AIRPORT:-KBOS}"
FG_RUNWAY="${FG_RUNWAY:-27}"
FG_ALTITUDE="${FG_ALTITUDE:-5000}"
FG_HEADING="${FG_HEADING:-0}"
FG_OFFSET_DIST="${FG_OFFSET_DIST:-4.72}"
FG_OFFSET_AZ="${FG_OFFSET_AZ:-0}"

# -------- Run --------
exec "$FG_APPIMAGE" \
  --fg-root="$FG_ROOT" \
  --aircraft="$FG_AIRCRAFT" \
  --fdm="network,${FG_FDM_HOST},${FG_FDM_IN},${FG_FDM_OUT},${FG_FDM_DATA}" \
  --multiplay="in,25,${FG_MP_HOST_IN},${FG_MP_IN_PORT}" \
  --multiplay="out,25,${FG_MP_HOST_OUT},${FG_MP_OUT_PORT}" \
  --enable-hud \
  --fog-fastest \
  --enable-clouds3d \
  --start-date-lat="$FG_START_DATE" \
  --disable-sound \
  --in-air \
  --enable-freeze \
  --airport="$FG_AIRPORT" \
  --runway="$FG_RUNWAY" \
  --altitude="$FG_ALTITUDE" \
  --heading="$FG_HEADING" \
  --offset-distance="$FG_OFFSET_DIST" \
  --offset-azimuth="$FG_OFFSET_AZ" \
  --enable-terrasync

