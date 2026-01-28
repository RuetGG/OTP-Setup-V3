FROM opentripplanner/opentripplanner:2.8.1

WORKDIR /var/otp/data

# Expose OTP HTTP port
EXPOSE 8080

# Clear the upstream image ENTRYPOINT so our CMD runs as the container's main process
ENTRYPOINT []

# If graph.obj missing, download from GitHub Releases; then start OTP.
# Using /bin/sh -c (POSIX shell). The upstream image includes /bin/sh.
CMD ["/bin/sh", "-c", "\
  set -euo pipefail; \
  if [ ! -f /var/otp/data/graph.obj ]; then \
    echo 'graph.obj not found. Downloading from GitHub Releases...'; \
    curl -L -f -o /var/otp/data/graph.obj 'https://github.com/RuetGG/OTP-Setup-V3/releases/download/v1/graph.obj'; \
    echo 'Download finished.'; \
  else \
    echo 'graph.obj already present, skipping download.'; \
  fi; \
  echo 'Contents of /var/otp/data:'; ls -lh /var/otp/data || true; \
  echo 'Starting OTP...'; \
  exec /usr/local/bin/otp --load /var/otp/data --serve --port 8080 --bind 0.0.0.0 \
"]
