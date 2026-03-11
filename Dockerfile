# Official Mendix Runtime-compatible root filesystem (public)
FROM mendix/rootfs:latest

# Copy the unzipped MDA produced by your workflow
COPY deployment/unzipped /opt/mendix/app

# Expose Mendix default port (change if you run on a different port)
EXPOSE 8080

# Add a robust healthcheck script
RUN mkdir -p /opt/mendix/health
ADD <<'EOF' /opt/mendix/health/check.sh
#!/usr/bin/env sh
set -eu

HOST="${HOST:-localhost}"
PORT="${PORT:-8080}"

# Prefer a dedicated health endpoint if your app exposes one
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

# Healthcheck configuration
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
  CMD /opt/mendix/health/check.sh
