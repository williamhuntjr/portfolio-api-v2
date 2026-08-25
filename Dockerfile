# --- build ---
FROM node:20-alpine AS build
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

WORKDIR /opt/app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ENV NODE_ENV=production
RUN npm run build

# --- production ---
FROM node:20-alpine AS production
RUN apk add --no-cache vips-dev

WORKDIR /opt/app
ENV NODE_ENV=production

RUN addgroup -S strapi && adduser -S strapi -G strapi

COPY --from=build --chown=strapi:strapi /opt/app/node_modules ./node_modules
COPY --from=build --chown=strapi:strapi /opt/app/package.json ./package.json
COPY --from=build --chown=strapi:strapi /opt/app/dist ./dist
COPY --from=build --chown=strapi:strapi /opt/app/public ./public
COPY --from=build --chown=strapi:strapi /opt/app/database ./database
COPY --from=build --chown=strapi:strapi /opt/app/.strapi ./.strapi
# Strapi 5 TS projects read config from these directly at runtime, not just
# the compiled dist/config output — omitting them breaks database config
# resolution (throws deep inside @strapi/database with a cryptic error).
COPY --from=build --chown=strapi:strapi /opt/app/config ./config
COPY --from=build --chown=strapi:strapi /opt/app/tsconfig.json ./tsconfig.json

# Ensure the upload mount point exists even if nothing is bind-mounted over it
# (docker-compose.yml normally mounts a host directory here — see volumes:).
RUN mkdir -p public/uploads && chown -R strapi:strapi public/uploads

USER strapi
EXPOSE 1337

CMD ["npm", "run", "start"]
