#!/bin/bash

# Detect OS
OS=$(uname -s)

# Start Docker Desktop based on OS
case $OS in
    Darwin)  # macOS
        echo "Starting Docker on macOS..."
        open -a Docker
        ;;
    Linux)   # Linux
        echo "Starting Docker on Linux..."
        # Ensure Docker service is started
        sudo systemctl start docker
        ;;
    CYGWIN*|MINGW*|MSYS*)  # Windows (Git Bash, WSL)
        echo "Starting Docker on Windows..."
        # For Git Bash or WSL, use PowerShell command to start Docker Desktop
        powershell.exe -Command "Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'"
        ;;
    *) 
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Wait for Docker to start
echo "Waiting for Docker to initialize..."
while ! docker info > /dev/null 2>&1; do
    sleep 2
done

echo "Docker is now running!"

# Run Docker container
docker run -d --rm -p 27017:27017 --name sportiverse-db \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=password \
mongo

# Run data import script
npm run data:import
