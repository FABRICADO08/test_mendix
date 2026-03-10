# Use Mendix runtime base image
FROM mendix/mendix-buildpack:latest

# Set working directory
WORKDIR /opt/app

# Copy the Mendix project
COPY . /opt/app

# Environment variables required by Mendix
ENV ADMIN_PASSWORD=Admin123!
ENV DATABASE_ENDPOINT=${DATABASE_ENDPOINT}
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USER=${DATABASE_USER}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}

# Expose Mendix port
EXPOSE 8080

# Start Mendix application
CMD ["/opt/app/buildpack/startup.sh"]