# Stage 1: Build
FROM node:20 AS build

# Set the working directory inside the container
WORKDIR /usr/src/app

# Add build argument for REACT_APP_BASE_API_URI
ARG REACT_APP_BASE_API_URI

# Set environment variable for the build
ENV REACT_APP_BASE_API_URI=${REACT_APP_BASE_API_URI}

# Echo the value of REACT_APP_BASE_API_URI for debugging
RUN echo "REACT_APP_BASE_API_URI is set to: $REACT_APP_BASE_API_URI"

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

RUN npm run build

# Stage 2: Production
FROM nginx:1.25-alpine AS production

# Copy built assets from the build stage to Nginx's static content directory
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]