FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402 AS build
WORKDIR /src
ENV HUSKY=0
RUN apk add --no-cache python3 make g++ chromium && npm install -g pnpm@9.0.5
COPY . .
RUN pnpm install --force --frozen-lockfile
RUN pnpm run build:shared && pnpm run build:server --skip-nx-cache
RUN pnpm --filter @bigcapital/server --prod deploy /runtime \
 && cp -a packages/server/dist /runtime/dist \
 && cp -a packages/server/public /runtime/public \
 && cp -a packages/server/static /runtime/static \
 && mkdir -p /runtime/src \
 && cp -a packages/server/src/database /runtime/src/database \
 && for pair in "bigcapital-utils:utils" "pdf-templates:pdf-templates" "email-components:email-components" "sdk-ts:sdk-ts"; do src=${pair%:*}; dest=${pair#*:}; mkdir -p "/runtime/node_modules/@bigcapital/$dest/dist"; cp -a "shared/$src/dist/." "/runtime/node_modules/@bigcapital/$dest/dist/"; done \
 && test -f /runtime/dist/main.js && test -f /runtime/dist/cli.js

FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402
WORKDIR /app
ENV NODE_ENV=production PORT=3000 NEW_RELIC_NO_CONFIG_FILE=true NEW_RELIC_ENABLED=false
COPY --from=build --chown=node:node /runtime/ /app/
COPY --from=build --chown=node:node /src/LICENSE /app/LICENSE
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
