FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY src/ ./src/

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3001

CMD ["node", "src/index.js"]