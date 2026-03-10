FROM mendix/rootfs:ubi8

WORKDIR /opt/mendix

# Copy the auto‑built MDA from the deployment folder
COPY deployment/*.mda /opt/mendix/app.mda

EXPOSE 8080

CMD ["/opt/mendix/run.sh"]
