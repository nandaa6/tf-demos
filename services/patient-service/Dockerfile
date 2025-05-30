# Use official Node.js LTS base image
FROM public.ecr.aws/docker/library/alpine:latest

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# # Install dependencies
# RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]



# Start the app