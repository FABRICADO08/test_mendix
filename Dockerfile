# --- Stage 1: Build and Compile ---
FROM mendix/mendix-buildpack:latest AS builder

# Copy your packaged app into the builder
COPY deployment/app.mda /tmp/app.mda

# The buildpack does the heavy lifting: downloading runtime, extracting, and generating startup scripts
RUN mkdir -p /opt/mendix/build \
 && /build/buildpack/compilation /tmp/app.mda /opt/mendix/build

# --- Stage 2: Runtime Execution ---
FROM mendix/rootfs:latest

# Copy the fully compiled app (which now includes the run.sh script)
COPY --from=builder /opt/mendix/build /opt/mendix/app

WORKDIR /opt/mendix/app

# Expose Mendix default port
EXPOSE 8080

# The buildpack generates run.sh, which is the official way to start Mendix
CMD ["/opt/mendix/app/run.sh"]

# --- Health check ---
RUN mkdir -p /opt/mendix/health
ADD <<'EOF' /opt/mendix/health/check.sh
#!/usr/bin/env sh
set -eu
HOST="${HOST:-localhost}"
PORT="${PORT:-8080}"
URLS="http://$HOST:$PORT/health http://$HOST:$PORT/"
has_cmd() { command -v "$1" >/dev/null 2>&1; }
for u in $URLS; do
  if has_cmd curl; then
    if curl --fail --silent --show-error "$u" >/dev/null 2>&1; then exit 0; fi
  elif has_cmd wget; then
    if wget -q --spider "$u" >/dev/null 2>&1; then exit 0; fi
  else
    echo "Health check prerequisites missing" >&2; exit 1
  fi
done
exit 1
EOF

RUN chmod +x /opt/mendix/health/check.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
  CMD /opt/mendix/health/check.sh
