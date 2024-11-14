#!/bin/bash

# Ensure the script fails on error
set -e

# Define the path to GoogleService-Info.plist
PLIST_FILE="AimTask/GoogleService-Info.plist"

# Fetch the API key from the environment variable
API_KEY=$GOOGLE_API_KEY

# Check if the API key is set
if [ -z "$API_KEY" ]; then
    echo "❌ Error: GOOGLE_API_KEY environment variable is not set."
    exit 1
fi

echo "✅ API Key found, replacing placeholder in GoogleService-Info.plist"

# Replace the placeholder in the plist file with the API key using PlistBuddy
/usr/libexec/PlistBuddy -c "Set :API_KEY $API_KEY" "$PLIST_FILE"

echo "✅ API Key successfully replaced in GoogleService-Info.plist"

