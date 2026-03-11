# Use the lightweight runtime base (official)
FROM mendix/rootfs:ubi8

# Set working directory (official uses /opt/mendix/build)
WORKDIR /opt/mendix/build

# Copy your pre-built MDA (your GitHub Action output)
COPY deployment/*.mda /opt/mendix/app.mda

# Copy the required startup scripts & buildpack (you must include these in your repo)
# Download them once from: https://github.com/mendix/docker-mendix-buildpack/tree/master/scripts
COPY scripts/startup /opt/mendix/build/startup
COPY scripts/vcap_application.json /opt/mendix/build/
# Also copy the full buildpack if needed (or use a builder stage)

# Set permissions (matches official)
RUN chown -R 1001:0 /opt/mendix && \
    chmod -R g+rwX /opt/mendix && \
    chmod +rx /opt/mendix/build/startup

# Expose port
EXPOSE 8080

# Correct entrypoint (this is what actually starts Mendix)
USER 1001
ENTRYPOINT ["/opt/mendix/build/startup"]
CMD ["/opt/mendix/buildpack/buildpack/start.py"]
