FROM opentripplanner/opentripplanner:2.8.1

WORKDIR /var/otp/data

USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY start-otp.sh /usr/local/bin/start-otp.sh
RUN chmod +x /usr/local/bin/start-otp.sh

ENTRYPOINT ["/usr/local/bin/start-otp.sh"]

EXPOSE 8080