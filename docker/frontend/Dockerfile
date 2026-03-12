FROM nginxinc/nginx-unprivileged:alpine

USER root
RUN apk update && apk upgrade
USER nginx

COPY --chown=nginx:nginx app/frontend/index.html /usr/share/nginx/html/
COPY --chown=nginx:nginx app/frontend/health.html /usr/share/nginx/html/
COPY --chown=nginx:nginx docker/frontend/default.conf /etc/nginx/conf.d/default.conf
