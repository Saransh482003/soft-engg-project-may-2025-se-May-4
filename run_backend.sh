#!/bin/bash

# Navigate to the backend directory
cd backend || { echo "backend directory not found!"; exit 1; }

# Creating a virtual environment
echo "Creating a virtual environment, with the name backend_venv..."
python3 -m venv backend_venv || { echo "Failed to create virtual environment. Please ensure Python 3 is installed."; exit 1; }

# Activate the virtual environment
source backend_venv/bin/activate || { echo "Failed to activate virtual environment. Please ensure you are using a compatible shell."; exit 1; }

# Upgrade pip to the latest version
echo "Upgrading pip to the latest version..." || { echo "Failed to upgrade pip. Please ensure Python 3 is installed."; exit 1; }

# Check if requirements.txt exists
if [ ! -f requirements.txt ]; then
    echo "requirements.txt not found! Please ensure it exists in the backend directory."
    exit 1
fi

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Run the backend application
echo "Starting the backend application..."
python app.py
