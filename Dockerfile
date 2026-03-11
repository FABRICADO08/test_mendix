# --- Stage 1: Unpack App and Fetch Runtime ---
FROM debian:stable-slim AS unpack
RUN apt-get update && apt-get install -y unzip curl && rm -rf /var/lib/apt/lists/*

# 1. Unpack the project logic
COPY deployment/app.mda /tmp/app.mda
RUN mkdir -p /opt/mendix/app && unzip -q /tmp/app.mda -d /opt/mendix/app

# 2. Download the Engine and strip the top-level folder
# This ensures bin/mx is exactly where we expect it
RUN curl -fsSL https://cdn.mendix.com/runtime/mendix-10.24.1.74050.tar.gz | tar -xz --strip-components=1 -C /opt/mendix/app

# --- Stage 2: Execution Image ---
FROM mendix/rootfs:latest

# Copy combined App + Runtime
COPY --from=unpack /opt/mendix/app /opt/mendix/app
WORKDIR /opt/mendix/app

# Now this will find the file correctly
RUN chmod +x ./bin/mx

# Expose the port Railway expects
EXPOSE 8080

# Start command
CMD ["./bin/mx", "run", "--port", "8080"]

# --- Health check ---
RUN mkdir -p /opt/mendix/health
# (Ensure your check.sh is copied or created here)
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
  CMD /opt/mendix/health/check.sh
