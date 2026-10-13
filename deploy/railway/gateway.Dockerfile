FROM nginx:1.27-alpine@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10
COPY deploy/railway/nginx.conf.template /etc/nginx/nginx.conf.template
COPY deploy/railway/gateway-entrypoint.sh /usr/local/bin/gateway-entrypoint.sh
RUN chmod +x /usr/local/bin/gateway-entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/gateway-entrypoint.sh"]
