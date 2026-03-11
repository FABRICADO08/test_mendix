# --- Stage 1: Unpack the Mendix MDA (needs unzip only in build stage)
FROM debian:stable-slim AS unpack
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Copy the packaged app produced by your workflow and committed to the repo
COPY deployment/app.mda /tmp/app.mda

# Unpack into a clean directory
RUN mkdir -p /opt/mendix/app \
 && unzip -q /tmp/app.mda -d /opt/mendix/app

# --- Stage 2: Runtime image (small, Mendix-compatible)
FROM mendix/rootfs:latest

# Bring the unpacked app into the runtime image
COPY --from=unpack /opt/mendix/app /opt/mendix/app

# Expose Mendix default port
EXPOSE 8080

# --- Health check (robust script) ---
RUN mkdir -p /opt/mendix/health
ADD <<'EOF' /opt/mendix/health/check.sh
#!/usr/bin/env sh
set -eu
HOST="${HOST:-localhost}"
PORT="${PORT:-8080}"
URLS="
http://$HOST:$PORT/health
http://$HOST:$PORT/
"
for u in $URLS; do
  if curl --fail --silent --show-error "$u" >/dev/null 2>&1; then
    exit 0
  fi
done
echo "Health check failed: none of $URLS responded with HTTP 200" >&2
exit 1
EOF
RUN chmod +x /opt/mendix/health/check.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s
