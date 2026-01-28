FROM opentripplanner/opentripplanner:2.8.1

WORKDIR /var/otp/data

# Copy start script into the image
COPY start-otp.sh /usr/local/bin/start-otp.sh
RUN chmod +x /usr/local/bin/start-otp.sh

# Use our script as the entrypoint
ENTRYPOINT ["/usr/local/bin/start-otp.sh"]

EXPOSE 8080