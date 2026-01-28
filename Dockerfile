FROM eclipse-temurin:17-jdk-alpine

WORKDIR /otp

# Install both curl and wget
RUN apk add --no-cache curl wget

RUN mkdir -p /otp/data

COPY . /otp/

EXPOSE 8080

# Use this script that handles Google Drive properly
CMD sh -c ' \
    echo "=== Starting OTP ===" && \
    echo "Downloading files..." && \
    \
    # Method 1: Try wget with cookie handling \
    wget --quiet --save-cookies /tmp/cookies.txt \
         "https://docs.google.com/uc?export=download&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh" -O- | \
    grep -o \'\''confirm=[0-9A-Za-z_]*\'\'' | \
    tail -1 | \
    xargs -I{} wget --quiet --load-cookies /tmp/cookies.txt \
         "https://docs.google.com/uc?export=download&{}\&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh" -O /otp/otp.jar && \
    \
    wget --quiet --save-cookies /tmp/cookies.txt \
         "https://docs.google.com/uc?export=download&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc" -O- | \
    grep -o \'\''confirm=[0-9A-Za-z_]*\'\'' | \
    tail -1 | \
    xargs -I{} wget --quiet --load-cookies /tmp/cookies.txt \
         "https://docs.google.com/uc?export=download&{}\&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc" -O /otp/data/graph.obj && \
    \
    rm -f /tmp/cookies.txt && \
    \
    echo "File sizes:" && \
    ls -lh /otp/otp.jar && \
    ls -lh /otp/data/graph.obj && \
    \
    echo "Starting OTP..." && \
    java -Xmx384M -Xms256M -jar otp.jar --load /otp/data --serve --port 8080 --bind 0.0.0.0 \
    '