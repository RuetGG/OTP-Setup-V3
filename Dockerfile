FROM opentripplanner/opentripplanner:2.8.1

WORKDIR /var/otp/data

# Ensure root for package install
USER root

# Install curl (apt-based image)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy start script and make it executable
COPY start-otp.sh /usr/local/bin/start-otp.sh
RUN chmod +x /usr/local/bin/start-otp.sh

# Use our script as ENTRYPOINT (it will exec java -> OTP)
ENTRYPOINT ["/usr/local/bin/start-otp.sh"]

EXPOSE 8080
