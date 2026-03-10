FROM mendix/mendix-runtime:latest

WORKDIR /opt/app

COPY deployment /opt/app/deployment

ENV ADMIN_PASSWORD=Admin123!

EXPOSE 8080

CMD ["/opt/app/startup.sh"]