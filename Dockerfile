# Use the lightweight runtime image
FROM mendix/rootfs:ubi8

# Set the working directory
WORKDIR /opt/mendix

# Copy the pre-built MDA from the deployment folder in your repo
# This works because your GitHub Action has already generated it
COPY deployment/*.mda /opt/mendix/app.mda

# Set necessary permissions (often required for the run script)
RUN chown -R 1001:0 /opt/mendix && chmod -R g+rwX /opt/mendix

# Standard Mendix ports
EXPOSE 8080

# Use the existing run script provided by the base image
CMD ["/opt/mendix/run.sh"]
