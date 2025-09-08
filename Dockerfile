# ---------- Build Stage ----------
FROM node:18-alpine AS builder

WORKDIR /app
COPY package.json ./
RUN npm install --legacy-peer-deps --no-audit --progress=false

COPY . .

# Build (Next.js will export automatically if output: 'export' is set)
RUN npm run build

# ---------- Nginx Stage ----------
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

ENV PORT=80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
