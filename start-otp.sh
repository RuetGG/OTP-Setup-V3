#!/bin/sh
set -eu

DATA_DIR=/var/otp/data
GRAPH=$DATA_DIR/graph.obj
RELEASE_URL="https://github.com/RuetGG/OTP-Setup-V3/releases/download/v1/graph.obj"

mkdir -p "$DATA_DIR"

if [ ! -f "$GRAPH" ]; then
  echo "graph.obj not found. Downloading from GitHub Releases..."
  i=0
  while [ $i -lt 3 ]; do
    i=$((i+1))
    echo "Attempt $i to download graph.obj..."
    if curl -L --fail -o "$GRAPH" "$RELEASE_URL"; then
      echo "Download succeeded"
      break
    else
      echo "Download failed"
      if [ $i -lt 3 ]; then echo "Retrying in 3s..."; sleep 3; fi
    fi
  done
  if [ ! -f "$GRAPH" ]; then
    echo "ERROR: could not download graph.obj after 3 attempts" >&2
    exit 1
  fi
else
  echo "graph.obj already present, skipping download."
fi

echo "Contents of $DATA_DIR:"
ls -lh "$DATA_DIR" || true

echo "Starting OTP..."
exec /usr/local/bin/otp --load "$DATA_DIR" --serve --port 8080 --bind 0.0.0.0