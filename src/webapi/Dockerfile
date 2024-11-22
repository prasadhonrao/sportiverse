# Stage 1: Build
FROM node:20 AS build

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Stage 2: Production
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app .

# Install only production dependencies
RUN npm install --only=production

# Set NODE_ENV to production for performance optimizations
ENV NODE_ENV=production

# Create a non-root user and switch to it for running the app
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
USER appuser

# Expose the port the app runs on
EXPOSE 5000

# Define the command to run the application
CMD ["npm", "start"]