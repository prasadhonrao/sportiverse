#!/bin/bash

# Path to your config.json file (adjust as necessary)
CONFIG_FILE="./public/config/config.json"

# Define the new base API URI (can be passed as an argument or set manually)
NEW_BASE_API_URI="$1"

# If no argument is passed, show an error and exit
if [ -z "$NEW_BASE_API_URI" ]; then
  echo "Error: BASE_API_URI is required"
  echo "Usage: ./update-config.sh <new_base_api_uri>"
  exit 1
fi

# Check if the config.json file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE not found!"
  exit 1
fi

# Update the BASE_API_URI in the config.json file
echo "Updating BASE_API_URI in config.json to $NEW_BASE_API_URI"

# Use sed to replace the BASE_API_URI value in config.json
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: sed needs an empty string for -i option
  sed -i "" "s|\"BASE_API_URI\": \".*\"|\"BASE_API_URI\": \"$NEW_BASE_API_URI\"|" "$CONFIG_FILE"
else
  # Linux: sed works with -i directly
  sed -i "s|\"BASE_API_URI\": \".*\"|\"BASE_API_URI\": \"$NEW_BASE_API_URI\"|" "$CONFIG_FILE"
fi

echo "Updated config.json successfully!"

# Now you can run the docker build and push commands
