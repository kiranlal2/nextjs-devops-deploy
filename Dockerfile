# ---------- Build Stage ----------
FROM node:18-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps --no-audit --progress=false
COPY . .

# Build and export static files
RUN npm run build && npm run export

# ---------- Nginx Stage ----------
FROM nginx:alpine

# Copy static files to nginx html folder
COPY --from=builder /app/out /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
