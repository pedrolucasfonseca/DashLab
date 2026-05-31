FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --include=dev

COPY src/ ./src/

EXPOSE 3001

CMD ["node", "src/index.js"]

FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/src ./src/

RUN addgroup -S addgroup && adduser && -S appuser -G appgroup

USER appuser

EXPOSE 3001

CMD ["node", "src/index.js"]