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

RUN npm run build

# Stage 2: Production
FROM nginx:1.25-alpine AS production

# Copy built assets from the build stage to Nginx's static content directory
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]