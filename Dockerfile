FROM mendix/rootfs:ubi8 AS builder

WORKDIR /build
COPY . /build

# Build the app (MxBuild runs here)
RUN /opt/mendix/build.sh /build

FROM mendix/rootfs:ubi8
WORKDIR /opt/mendix

# Copy the generated MDA output
COPY --from=builder /build/build/mendix/app.mda /opt/mendix/app.mda

EXPOSE 8080
CMD ["/opt/mendix/run.sh"]