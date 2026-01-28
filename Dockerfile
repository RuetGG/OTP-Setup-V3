# Use official OTP image
FROM opentripplanner/opentripplanner:2.8.1

# Set working directory to OTP data folder
WORKDIR /var/otp/data

# Expose OTP port
EXPOSE 8080

# Start OTP and download graph.obj if missing
CMD ["sh", "-c", "\
echo '=== Starting OTP ===' && \
if [ ! -f /var/otp/data/graph.obj ]; then \
  echo 'graph.obj not found, downloading from GitHub Releases...' && \
  curl -L -o /var/otp/data/graph.obj \
  https://github.com/RuetGG/OTP-Setup-V3/releases/download/v1/graph.obj ; \
fi && \
echo 'File sizes:' && ls -lh /var/otp/data && \
echo 'Starting OTP server...' && \
exec /usr/local/bin/otp --load /var/otp/data --serve --port 8080 --bind 0.0.0.0 \
"]