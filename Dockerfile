# Use the official Mendix rootfs base image (compatible with Mendix 10.x)
FROM mendix/rootfs:ubi8

# Set work directory
WORKDIR /opt/mendix

# Copy the MDA package into the image
COPY deployment/*.mda /opt/mendix/app.mda

# Expose default Mendix port
EXPOSE 8080

# Start the app using the Mendix runtime starter
CMD ["/opt/mendix/run.sh"]