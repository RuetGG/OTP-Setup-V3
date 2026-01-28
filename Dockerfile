FROM opentripplanner/opentripplanner:2.8.1

WORKDIR /var/otp/data

EXPOSE 8080

# Clear upstream entrypoint so our CMD runs as PID 1
ENTRYPOINT []

# If graph.obj is missing, try to download it (3 attempts). Then start OTP.
CMD ["/bin/sh", "-c", "\
  set -eu; \
  if [ ! -f /var/otp/data/graph.obj ]; then \
    echo 'graph.obj not found. Downloading from GitHub Releases...'; \
    i=0; \
    while [ $i -lt 3 ]; do \
      i=$((i+1)); \
      echo \"Attempt $i to download graph.obj...\"; \
      if curl -L --fail -o /var/otp/data/graph.obj 'https://github.com/RuetGG/OTP-Setup-V3/releases/download/v1/graph.obj'; then \
        echo 'Download succeeded'; \
        break; \
      else \
        echo 'Download failed'; \
        if [ $i -lt 3 ]; then echo 'Retrying in 3s...'; sleep 3; fi; \
      fi; \
    done; \
    if [ ! -f /var/otp/data/graph.obj ]; then echo 'ERROR: could not download graph.obj after 3 attempts' >&2; exit 1; fi; \
  else \
    echo 'graph.obj already present, skipping download.'; \
  fi; \
  echo 'Contents of /var/otp/data:'; ls -lh /var/otp/data || true; \
  echo 'Starting OTP...'; \
  exec /usr/local/bin/otp --load /var/otp/data --serve --port 8080 --bind 0.0.0.0 \
"]