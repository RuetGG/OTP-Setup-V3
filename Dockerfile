# Use Java 17
FROM openjdk:17-jdk-slim

WORKDIR /otp

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create data folder
RUN mkdir -p /otp/data

# Copy local GTFS data if exists
COPY data/gtfs.zip /otp/data/gtfs.zip 2>/dev/null || true

# Function to download from Google Drive (handles large files)
RUN echo '#!/bin/bash\n\
download_from_gdrive() {\n\
    fileid="$1"\n\
    filename="$2"\n\
    echo "Downloading $filename from Google Drive..."\n\
    \n\
    # First get the confirmation code\n\
    confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=${fileid}" -O- | sed -rn "s/.*confirm=([0-9A-Za-z_]+).*/\\1\\n/p")\n\
    \n\
    # Then download with the confirmation code\n\
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=${confirm}&id=${fileid}" -O "${filename}"\n\
    \n\
    rm -f /tmp/cookies.txt\n\
    echo "Download completed: $filename"\n\
}\n\
\n\
# Download OTP JAR file\n\
if [ ! -f "/otp/otp.jar" ]; then\n\
    download_from_gdrive "1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh" "/otp/otp.jar"\n\
fi\n\
\n\
# Download graph.obj file\n\
if [ ! -f "/otp/data/graph.obj" ]; then\n\
    download_from_gdrive "1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc" "/otp/data/graph.obj"\n\
fi\n\
\n\
# Check if files exist\n\
if [ ! -f "/otp/otp.jar" ]; then\n\
    echo "ERROR: otp.jar not found!"\n\
    exit 1\n\
fi\n\
\n\
if [ ! -f "/otp/data/graph.obj" ]; then\n\
    echo "ERROR: graph.obj not found!"\n\
    exit 1\n\
fi\n\
\n\
if [ ! -f "/otp/data/gtfs.zip" ]; then\n\
    echo "WARNING: gtfs.zip not found in data/ folder"\n\
fi\n\
\n\
echo "Starting OTP server..."\n\
exec java -Xmx2G -Xms512M -jar otp.jar --load /otp/data --serve' > /otp/start.sh \
    && chmod +x /otp/start.sh

# Expose OTP port
EXPOSE 8080

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8080/otp/ || exit 1

# Start OTP server
CMD ["/otp/start.sh"]