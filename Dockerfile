# Use Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all code
COPY . .

# Build the app
RUN npm run build

# Start the app
CMD ["npm", "start"]
