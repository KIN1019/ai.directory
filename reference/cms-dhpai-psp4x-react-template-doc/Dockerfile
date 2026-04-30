ARG builder_image=artifactrepo.server.ha.org.hk:55743/docker-dev-chassis/node:20.9.0-alpine
ARG source_image=artifactrepo.server.ha.org.hk:55743/docker-rel-chassis/rhel8/nginx-120:1.20.1-5.1638356804

# stage 1 : building the code
FROM ${builder_image} AS builder
WORKDIR /build

ARG NPMRC_AUTH

COPY . .
# Build the code, output at "/build/build"
RUN npm run build

# stage 2 : package the html into the nginx container
FROM ${source_image}
WORKDIR /app

# Setup /logs and /app folders
USER root
RUN mkdir /logs && chmod a+rw /logs /app
USER default

# Update API svc URLs at nginx configurations
RUN printf '%s\n' \
  '#!/bin/bash' \
  'echo "** Update API svc URLs at nginx configurations **"' \
  'mkdir -p /logs/$KUBERNETES_POD_NAME' \
  "envsubst '\$KUBERNETES_POD_NAME,\$KUBERNETES_NAMESPACE,\$ALERT_PROJECT_CODE' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf" \
  "envsubst '\$PLACEHOLDER_APP_VERSION' < /opt/app-root/etc/nginx.default.d/nginx-cms-app.conf.template > /opt/app-root/etc/nginx.default.d/nginx-cms-app.conf" \
  > /opt/app-root/src/nginx-start/nginx-proxy-envsubst.sh

COPY nginx.conf /etc/nginx/nginx.conf.template
COPY nginx-cms-app.conf /opt/app-root/etc/nginx.default.d/nginx-cms-app.conf.template

# copy the built as template, the replace with env variables
COPY --from=builder /build/build /app/html-template
RUN printf '%s\n' \
  '#!/bin/bash' \
  'echo "** Update API svc URLs at codes **"' \
  'cp -r /app/html-template /app/html' \
  "envsubst '\$PLACEHOLDER_MY_SVC_URL' < /app/html-template/remoteEntry.js > /app/html/remoteEntry.js" \
  'echo ""' \
  > /opt/app-root/src/nginx-start/nginx-code-envsubst.sh

EXPOSE 8080

ENTRYPOINT ["/usr/libexec/s2i/run"]
