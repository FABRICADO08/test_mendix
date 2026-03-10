FROM mendix/runtime:10

WORKDIR /opt/mendix

COPY deployment/*.mda /opt/mendix/app.mda

EXPOSE 8080

CMD ["sh", "-c", "echo Starting Mendix app"]