# Use Eclipse Temurin with Alpine - smallest and most reliable
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /otp

# Install curl
RUN apk add --no-cache curl

# Create data directory
RUN mkdir -p /otp/data

# Copy any local files
COPY . /otp/

# Expose port
EXPOSE 8080

# Download and run with retry logic
CMD sh -c ' \
    echo "=== Starting OTP on Render ===" && \
    echo "Downloading otp.jar..." && \
    curl -L -o /otp/otp.jar "https://drive.google.com/uc?export=download&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh" && \
    echo "Downloading graph.obj..." && \
    curl -L -o /otp/data/graph.obj "https://drive.google.com/uc?export=download&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc" && \
    echo "Starting OTP server..." && \
    java -Xmx384M -Xms256M -jar otp.jar --load /otp/data --serve --port 8080 --bind 0.0.0.0 \
    '