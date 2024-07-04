#!/bin/bash

# Prompt for the Telegram API token and admin ID
read -p "Masukkan API key bot: " TELEGRAM_API_TOKEN
read -p "Masukkan chat ID: " TELEGRAM_ADMIN_ID

# Define the path to the .env file
ENV_FILE="/opt/marzban/.env"

# Modify the .env file
sed -i "s|# TELEGRAM_API_TOKEN = .*|TELEGRAM_API_TOKEN = \"$TELEGRAM_API_TOKEN\"|g" $ENV_FILE
sed -i "s|# TELEGRAM_ADMIN_ID = .*|TELEGRAM_ADMIN_ID = $TELEGRAM_ADMIN_ID|g" $ENV_FILE

# ANSI escape code for green text
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Print success message in green
echo -e "${GREEN}API key bot dan chat ID telah berhasil ditambahkan cok!${NC}"

# Restart Marzban service silently in the background
nohup marzban restart &> /dev/null &
echo "Marzban service is restarting in the background."
