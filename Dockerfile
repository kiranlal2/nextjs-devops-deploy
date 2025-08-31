# ---------- Build Stage ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Install deps (clean install, includes devDependencies for build)
COPY package*.json ./
RUN npm ci

# Copy all source code
COPY . .

# Build Next.js
RUN npm run build


# ---------- Run Stage ----------
FROM node:18-alpine AS runner

WORKDIR /app

# Copy only package.json for production install
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy built assets from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose Next.js port
EXPOSE 3000

# Run Next.js in production mode
CMD ["npm", "run", "start"]
