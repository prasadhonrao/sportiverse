#!/bin/bash

# Ensure the correct URI is passed as an argument to the update-config.sh script
BASE_API_URI=$1

# Call the update-config.sh script to update the value of BASE_API_URI
./update-config.sh "$BASE_API_URI"

# Now, build and push the Docker image
docker build -t prasadhonrao/sportiverse-webapp:dev .
docker push prasadhonrao/sportiverse-webapp:dev
