FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402 AS build
WORKDIR /src
ENV HUSKY=0
RUN apk add --no-cache python3 make g++ chromium && npm install -g pnpm@9.0.5
COPY . .
RUN pnpm install --force --frozen-lockfile
RUN pnpm run build:webapp

FROM nginx:1.27-alpine@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10
COPY packages/webapp/nginx/sites/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/packages/webapp/dist /usr/share/nginx/html
EXPOSE 80
