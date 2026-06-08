FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM alpine:3.19 AS production
WORKDIR /app
ENV NODE_ENV=production

RUN apk add --no-cache nodejs

COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY package*.json ./

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3001
CMD ["node", "src/index.js"]