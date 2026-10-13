FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402
WORKDIR /app
RUN apk add --no-cache mariadb-client && npm install --omit=dev @aws-sdk/client-s3@3.576.0
COPY deploy/railway/backup.mjs /app/backup.mjs
USER node
CMD ["node", "backup.mjs"]
