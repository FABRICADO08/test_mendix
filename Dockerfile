# --- Stage 1: Unpack the Mendix MDA (only unzip needed here)
FROM debian:stable-slim AS unpack
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Copy the packaged app produced by your workflow and committed to the repo
COPY deployment/app.mda /tmp/app.mda

# Unpack into a clean directory
RUN mkdir -p /opt/mendix/app \
 && unzip -q /tmp/app.mda -d /opt/mendix/app

# --- Stage 2: Runtime image (Mendix-compatible rootfs)
FROM mendix/rootfs:latest

# Bring the unpacked app into the runtime image
COPY --from=unpack /opt/mendix/app /opt/mendix/app

# Expose Mendix default port
EXPOSE 8080


# ✅ ADD THIS - Start the Mendix runtime
#CMD ["/opt/mendix/bin/mx", "run", "--port", "8080"]
CMD ["/opt/mendix/mxruntime/bin/mx", "run"]



# --- Health check (robust, works with curl or wget if available) ---
RUN mkdir -p /opt/mendix/health
ADD <<'EOF' /opt/mendix/health/check.sh
#!/usr/bin/env sh
set -eu

HOST="${HOST:-localhost}"
PORT="${PORT:-8080}"

# Prefer a dedicated health endpoint; fall back to "/"
URLS="
http://$HOST:$PORT/health
http://$HOST:$PORT/
"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

for u in $URLS; do
  if has_cmd curl; then
    if curl --fail --silent --show-error "$u" >/dev/null 2>&1; then
      exit 0
    fi
  elif has_cmd wget; then
    if wget -q --spider "$u" >/dev/null 2>&1; then
      exit 0
    fi
  else
    echo "Health check prerequisites missing: need curl or wget in image" >&2
    exit 1
  fi
done

echo "Health check failed: none of $URLS responded with HTTP 200" >&2
exit 1
EOF
RUN chmod +x /opt/mendix/health/check.sh

# ✅ The missing CMD is here:
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
  CMD /opt/mendix/health/check.sh
