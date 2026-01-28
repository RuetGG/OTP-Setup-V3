# Use Alpine Linux with OpenJDK 17 - smallest image
FROM openjdk:17-alpine

WORKDIR /otp

# Install curl
RUN apk add --no-cache curl

# Create data directory
RUN mkdir -p /otp/data

# Copy any local files
COPY . /otp/

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/otp/ || exit 1

# Download and run with retry logic
CMD sh -c ' \
    echo "=== OTP Deployment on Render ===" && \
    echo "Downloading otp.jar..." && \
    for i in 1 2 3; do \
        curl -L -o /otp/otp.jar "https://drive.google.com/uc?export=download&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh" && break || \
        echo "Attempt $i failed, retrying..." && sleep 5; \
    done && \
    echo "Downloading graph.obj..." && \
    for i in 1 2 3; do \
        curl -L -o /otp/data/graph.obj "https://drive.google.com/uc?export=download&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc" && break || \
        echo "Attempt $i failed, retrying..." && sleep 5; \
    done && \
    echo "Starting OTP server on port 8080..." && \
    java -Xmx384M -Xms256M -jar otp.jar --load /otp/data --serve --port 8080 --bind 0.0.0.0 \
    '