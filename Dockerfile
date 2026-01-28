FROM eclipse-temurin:17-jdk-alpine

WORKDIR /otp

# Install required tools
RUN apk add --no-cache curl wget

# Create data directory
RUN mkdir -p /otp/data

EXPOSE 8080

CMD ["sh", "-c", "\
echo '=== Starting OTP ===' && \
echo 'Downloading files...' && \
wget --quiet --save-cookies /tmp/cookies.txt \
  'https://docs.google.com/uc?export=download&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh' -O- | \
  grep -o 'confirm=[0-9A-Za-z_]*' | tail -1 | \
  xargs -I{} wget --quiet --load-cookies /tmp/cookies.txt \
  'https://docs.google.com/uc?export=download&{}&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh' \
  -O /otp/otp.jar && \
wget --quiet --save-cookies /tmp/cookies.txt \
  'https://docs.google.com/uc?export=download&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc' -O- | \
  grep -o 'confirm=[0-9A-Za-z_]*' | tail -1 | \
  xargs -I{} wget --quiet --load-cookies /tmp/cookies.txt \
  'https://docs.google.com/uc?export=download&{}&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc' \
  -O /otp/data/graph.obj && \
rm -f /tmp/cookies.txt && \
echo 'File sizes:' && \
ls -lh /otp/otp.jar && \
ls -lh /otp/data/graph.obj && \
echo 'Starting OTP...' && \
exec java -Xmx384M -Xms256M -jar /otp/otp.jar \
  --load /otp/data \
  --serve \
  --port 8080 \
  --bind 0.0.0.0 \
"]