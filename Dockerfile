# ---------- Build Stage ----------
FROM node:18-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps --no-audit --progress=false
COPY . .

# Build (Next.js will export automatically if output: 'export' is set)
RUN npm run build

# ---------- Nginx Stage ----------
FROM nginx:alpine

COPY --from=builder /app/out /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
