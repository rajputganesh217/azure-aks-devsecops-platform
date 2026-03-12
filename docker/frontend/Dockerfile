FROM nginxinc/nginx-unprivileged:alpine

# Security: Apply latest patches
USER root
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*
USER nginx

# Copy static assets
COPY --chown=nginx:nginx app/frontend/index.html /usr/share/nginx/html/
COPY --chown=nginx:nginx app/frontend/health.html /usr/share/nginx/html/

# Custom configuration
COPY --chown=nginx:nginx docker/frontend/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
