# Official Mendix pre-built MDA Docker image (March 2026)
# No extra scripts folder needed - super simple and reliable

FROM mendix/docker-mendix-buildpack:latest

# Copy the unzipped MDA (created automatically by the workflow)
COPY deployment/unzipped /opt/mendix/build
