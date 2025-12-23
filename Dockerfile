FROM nginx:1.29.4-alpine
# FROM dhi.io/nginx:1-alpine3.21

RUN apk add --no-cache curl gettext \
  && rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY health.conf.template /etc/nginx/health.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
