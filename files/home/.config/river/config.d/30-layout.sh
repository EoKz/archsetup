#!/usr/bin/env sh

if command -v rivertile >/dev/null 2>&1; then
  pkill -x rivertile 2>/dev/null || true

  rivertile \
    -view-padding 6 \
    -outer-padding 8 &

  riverctl default-layout rivertile
fi
