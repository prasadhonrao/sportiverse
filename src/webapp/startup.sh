#!/bin/bash

# Azure App Service startup script for React app
# This script updates the config.json file with the correct API URL and starts the app

echo "🚀 Starting Sportiverse Web App..."

# Check if API_BASE_URL environment variable is set
if [ -z "$API_BASE_URL" ]; then
  echo "⚠️  Warning: API_BASE_URL environment variable not set. Using default from config.json"
else
  echo "🔧 Updating config.json with API_BASE_URL: $API_BASE_URL"
  
  # Path to config.json
  CONFIG_FILE="/home/site/wwwroot/config/config.json"
  
  # Update the BASE_API_URI in config.json
  if [ -f "$CONFIG_FILE" ]; then
    # Use sed to replace the BASE_API_URI value
    sed -i "s|\"BASE_API_URI\": \".*\"|\"BASE_API_URI\": \"$API_BASE_URL\"|" "$CONFIG_FILE"
    echo "✅ Updated config.json successfully!"
    
    # Verify the update
    echo "📋 Current config.json content:"
    cat "$CONFIG_FILE"
  else
    echo "❌ Error: $CONFIG_FILE not found!"
  fi
fi

echo "🌐 Starting web server..."

# Start the application
# For production builds served with serve
if [ -d "/home/site/wwwroot/build" ]; then
  echo "📦 Serving production build..."
  cd /home/site/wwwroot
  npx serve -s build -l 3000
else
  echo "🔧 Starting development server..."
  cd /home/site/wwwroot
  npm start
fi
