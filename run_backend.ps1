# Navigate to the backend directory
Set-Location -Path ".\backend" -ErrorAction Stop

# Create virtual environment
Write-Host "Creating a virtual environment named 'backend_venv'..."
python -m venv backend_venv
if (-Not (Test-Path ".\backend_venv")) {
    Write-Error "Failed to create virtual environment. Please ensure Python 3 is installed."
    exit 1
}

# Activate the virtual environment
Write-Host "Activating virtual environment..."
& .\backend_venv\Scripts\Activate.ps1
if (-Not $env:VIRTUAL_ENV) {
    Write-Error "Failed to activate virtual environment."
    exit 1
}

# Upgrade pip
Write-Host "Upgrading pip to the latest version..."
python -m pip install --upgrade pip

# Check for requirements.txt
if (-Not (Test-Path ".\requirements.txt")) {
    Write-Error "requirements.txt not found! Please ensure it exists in the backend directory."
    exit 1
}

# Install dependencies
Write-Host "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Run the backend app
Write-Host "Starting the backend application..."
python app.py
