# Use Java 17
FROM eclipse-temurin:17-jdk

WORKDIR /otp

# Create data folder
RUN mkdir -p /otp/data

# Copy GTFS from Git repo
COPY data/gtfs.zip /otp/data/gtfs.zip

# Download prebuilt graph.obj from Google Drive
RUN curl -L -o /otp/data/graph.obj "https://drive.google.com/uc?export=download&id=1tdALzkrgxhhjIsF-DEs3XgEDNsC8QWHc"
RUN curl -L -o /otp/otp.jar "https://drive.google.com/uc?export=download&id=1Up4Ypph45B2W5WuX1TGMXpRElrtcgUBh"

# Expose OTP port
EXPOSE 8080

# Start OTP server (memory safe for Render Free)
CMD ["java", "-Xmx512M", "-jar", "otp.jar", "--load", "/otp/data", "--serve"]