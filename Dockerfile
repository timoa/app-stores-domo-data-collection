FROM node:16.16.0-alpine3.15@sha256:42a6ab6498b9d8915bb884cf40ded56e9f79d27837ecddf4852988999c68dd7a
ARG appPort=9514

LABEL maintainer="Damien Laureaux <d.laureaux@timoa.com>" \
      org.label-schema.vendor="Timoa" \
      org.label-schema.name="App stores DOMO Data Collection" \
      org.label-schema.description="App stores DOMO Data Collection" \
      org.label-schema.url="https://timoa.com" \
      org.label-schema.vcs-url="https://github.com/timoa/app-stores-domo-dataset" \
      org.label-schema.version=latest \
      org.label-schema.schema-version="1.0"

RUN \
      apk --no-cache update && \
      apk --no-cache upgrade && \
      apk add --no-cache ca-certificates && update-ca-certificates && \
      rm -rf /var/cache/apk/* && \
      npm install -g npm@latest && \
      mkdir -p /opt/app && \
      adduser -S app-user

WORKDIR /opt/app/
COPY ./package.json ./
COPY ./src ./src

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s \
      CMD npm run docker:status

RUN \
      npm install --production --unsafe-perm && \
      npm cache clean --force

RUN chown -R app-user /opt/app
USER app-user

EXPOSE ${appPort}
CMD [ "npm", "start" ]
