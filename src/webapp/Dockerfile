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

# Set build-time environment variables
ARG REACT_APP_SPORTIVERSE_BASE_API_URI
ENV REACT_APP_SPORTIVERSE_BASE_API_URI=${REACT_APP_SPORTIVERSE_BASE_API_URI}

# Stage 2: Production
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app .

# Install only production dependencies
RUN npm install --only=production

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "start"]