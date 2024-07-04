#!/bin/bash

# Prompt for the Telegram API token and admin ID
read -p "Masukkan API key bot: " TELEGRAM_API_TOKEN
read -p "Masukkan chat ID: " TELEGRAM_ADMIN_ID

# Define the path to the .env file
ENV_FILE="/opt/marzban/.env"

# Modify the .env file
sed -i "s|# TELEGRAM_API_TOKEN = .*|TELEGRAM_API_TOKEN = \"$TELEGRAM_API_TOKEN\"|g" $ENV_FILE
sed -i "s|# TELEGRAM_ADMIN_ID = .*|TELEGRAM_ADMIN_ID = $TELEGRAM_ADMIN_ID|g" $ENV_FILE

echo "API key bot dan chat ID telah berhasil ditambahkan ke Pepek $ENV_FILE"

# Restart Marzban service silently
marzban restart &> /dev/null
