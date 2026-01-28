#!/bin/sh
set -eu

DATA_DIR=/var/otp/data
GRAPH="$DATA_DIR/graph.obj"
RELEASE_URL="https://github.com/RuetGG/OTP-Setup-V3/releases/download/v1/graph.obj"

mkdir -p "$DATA_DIR"

# 1) Download graph if missing (3 attempts)
if [ ! -f "$GRAPH" ]; then
  echo "graph.obj not found. Downloading from GitHub Releases..."
  i=0
  while [ $i -lt 3 ]; do
    i=$((i+1))
    echo "Attempt $i to download graph.obj..."
    if command -v curl >/dev/null 2>&1 && curl -L --fail -o "$GRAPH" "$RELEASE_URL"; then
      echo "Download succeeded"
      break
    else
      echo "Download failed"
      if [ $i -lt 3 ]; then
        echo "Retrying in 3s..."
        sleep 3
      fi
    fi
  done

  if [ ! -f "$GRAPH" ]; then
    echo "ERROR: could not download graph.obj after 3 attempts" >&2
    exit 1
  fi
else
  echo "graph.obj already present, skipping download."
fi

# 2) Show contents for logs
echo "Contents of $DATA_DIR:"
ls -lh "$DATA_DIR" || true

# 3) Find OTP entrypoint / jar
echo "Locating OTP runtime..."

# Prefer otp executable if in PATH
if command -v otp >/dev/null 2>&1; then
  echo "Found 'otp' executable in PATH. Will use it."
  echo "Starting OTP via 'otp'..."
  exec otp --load "$DATA_DIR" --serve --port 8080 --bind 0.0.0.0
fi

# Candidate jar paths to check (common locations)
CANDIDATES="
/usr/local/share/java/otp.jar
/usr/local/share/java/otp-shaded.jar
/opt/opentripplanner/otp-shaded.jar
/opt/opentripplanner/otp.jar
/opt/opentripplanner/otp-shaded/otp-shaded.jar
/opt/otp/otp.jar
/usr/local/lib/otp.jar
"

JAR_PATH=""
for p in $CANDIDATES; do
  if [ -f "$p" ]; then
    JAR_PATH="$p"
    echo "Found OTP jar at: $JAR_PATH"
    break
  fi
done

# If not found in candidates, search filesystem (stop on first match)
if [ -z "$JAR_PATH" ]; then
  echo "No OTP jar in common paths; searching filesystem (this may take a moment)..."
  # find first jar that looks like otp or shaded
  JAR_PATH=$(find / -type f \( -iname '*otp*.jar' -o -iname '*shaded*.jar' -o -iname 'otp-*.jar' \) -print -quit 2>/dev/null || true)
  if [ -n "$JAR_PATH" ]; then
    echo "Found OTP jar by search: $JAR_PATH"
  fi
fi

if [ -z "$JAR_PATH" ]; then
  echo "ERROR: Could not locate OTP jar or 'otp' executable in the image." >&2
  echo "You can either use an image that provides otp/otp.jar or update the Dockerfile to place the jar at /usr/local/share/java/otp.jar" >&2
  exit 2
fi

# 4) Launch OTP with java -jar
echo "Starting OTP via java -jar $JAR_PATH ..."
# Adjust memory flags if you want (REPORT: Render default memory limits)
exec java -Xmx1G -Xms512M -jar "$JAR_PATH" --load "$DATA_DIR" --serve --port 8080 --bind 0.0.0.0