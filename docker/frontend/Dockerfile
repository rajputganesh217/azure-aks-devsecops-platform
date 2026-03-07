FROM nginx:alpine

RUN apk update && apk upgrade

COPY app/frontend/index.html /usr/share/nginx/html/
COPY app/frontend/health.html /usr/share/nginx/html/
COPY docker/frontend/default.conf /etc/nginx/conf.d/default.conf
