# PowerShell script to run the Shravan application
# This script sets up and runs both the Flask backend and VueJS frontend

Write-Host "🚀 Starting Shravan Application Setup..." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow

# Function to check if command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Cyan

if (-not (Test-Command python)) {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.8+ and add it to your PATH" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Command npm)) {
    Write-Host "❌ npm is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js and npm" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Prerequisites check passed!" -ForegroundColor Green
Write-Host ""

# Backend Setup
Write-Host "🐍 Setting up Python Backend..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Yellow

try {
    # Navigate to Backend directory
    Set-Location -Path "Backend"
    Write-Host "📁 Navigated to Backend directory" -ForegroundColor Green
    
    # Create virtual environment if it doesn't exist
    if (-not (Test-Path "env")) {
        Write-Host "🔧 Creating Python virtual environment..." -ForegroundColor Yellow
        python -m venv env
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create virtual environment"
        }
        Write-Host "✅ Virtual environment created successfully!" -ForegroundColor Green
    } else {
        Write-Host "✅ Virtual environment already exists!" -ForegroundColor Green
    }
    
    # Activate virtual environment
    Write-Host "🔄 Activating virtual environment..." -ForegroundColor Yellow
    & ".\env\Scripts\Activate.ps1"
    
    # Install requirements
    Write-Host "📦 Installing Python dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Python dependencies"
    }
    Write-Host "✅ Python dependencies installed successfully!" -ForegroundColor Green
    
    # Start Flask backend in background
    Write-Host "🌐 Starting Flask backend..." -ForegroundColor Yellow
    Start-Process -FilePath "python" -ArgumentList "app.py" -WindowStyle Minimized
    Write-Host "✅ Flask backend started successfully!" -ForegroundColor Green
    Write-Host "🔗 Backend running at: http://localhost:5000" -ForegroundColor Cyan
    
    # Return to root directory
    Set-Location -Path ".."
    
} catch {
    Write-Host "❌ Backend setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}

Write-Host ""

# Frontend Setup
Write-Host "🌐 Setting up VueJS Frontend..." -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Yellow

try {
    # Navigate to frontend directory
    Set-Location -Path "Frontend"
    Write-Host "📁 Navigated to Frontend directory" -ForegroundColor Green
    
    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "📦 Installing npm dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install npm dependencies"
        }
        Write-Host "✅ npm dependencies installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "✅ npm dependencies already installed!" -ForegroundColor Green
    }
    
    # Start Vue development server
    Write-Host "🚀 Starting VueJS development server..." -ForegroundColor Yellow
    Write-Host "🔗 Frontend will be available at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "🎉 Shravan Application is now running!" -ForegroundColor Green
    Write-Host "📱 Backend API: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "🌐 Frontend App: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
    
    # Start the development server (this will block until stopped)
    npm run dev
    
} catch {
    Write-Host "❌ Frontend setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
} finally {
    # Return to root directory
    Set-Location -Path ".."
}

Write-Host ""
Write-Host "👋 Thank you for using Shravan!" -ForegroundColor Green
Write-Host "🏥 Your companion for a graceful age" -ForegroundColor Cyan