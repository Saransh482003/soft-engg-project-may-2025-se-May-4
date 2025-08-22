#!/bin/bash

# Bash script to run the Shravan application
# This script sets up and runs both the Flask backend and VueJS frontend

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${GREEN}🚀 Starting Shravan Application Setup...${NC}"
echo -e "${YELLOW}==========================================${NC}"

# Check prerequisites
print_info "📋 Checking prerequisites..."

if ! command_exists python3; then
    print_error "❌ Python3 is not installed or not in PATH"
    print_warning "Please install Python 3.8+ and add it to your PATH"
    exit 1
fi

if ! command_exists npm; then
    print_error "❌ npm is not installed or not in PATH"
    print_warning "Please install Node.js and npm"
    exit 1
fi

print_status "✅ Prerequisites check passed!"
echo ""

# Backend Setup
print_info "🐍 Setting up Python Backend..."
echo -e "${YELLOW}================================${NC}"

# Navigate to Backend directory
if [ ! -d "Backend" ]; then
    print_error "❌ Backend directory not found"
    exit 1
fi

cd Backend || {
    print_error "❌ Failed to navigate to Backend directory"
    exit 1
}

print_status "📁 Navigated to Backend directory"

# Create virtual environment if it doesn't exist
if [ ! -d "env" ]; then
    print_warning "🔧 Creating Python virtual environment..."
    python3 -m venv env
    if [ $? -ne 0 ]; then
        print_error "❌ Failed to create virtual environment"
        cd ..
        exit 1
    fi
    print_status "✅ Virtual environment created successfully!"
else
    print_status "✅ Virtual environment already exists!"
fi

# Activate virtual environment
print_warning "🔄 Activating virtual environment..."
source env/bin/activate

# Install requirements
print_warning "📦 Installing Python dependencies..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    print_error "❌ Failed to install Python dependencies"
    cd ..
    exit 1
fi
print_status "✅ Python dependencies installed successfully!"

# Start Flask backend in background
print_warning "🌐 Starting Flask backend..."
python app.py &
BACKEND_PID=$!
print_status "✅ Flask backend started successfully!"
print_info "🔗 Backend running at: http://localhost:5000"

# Function to cleanup background processes
cleanup() {
    echo ""
    print_warning "🛑 Shutting down application..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        print_status "✅ Backend stopped"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        print_status "✅ Frontend stopped"
    fi
    print_status "👋 Thank you for using Shravan!"
    print_info "🏥 Your companion for a graceful age"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Return to root directory
cd ..

echo ""

# Frontend Setup
print_info "🌐 Setting up VueJS Frontend..."
echo -e "${YELLOW}===============================${NC}"

# Navigate to frontend directory
if [ ! -d "Frontend" ]; then
    print_error "❌ Frontend directory not found"
    cleanup
    exit 1
fi

cd Frontend || {
    print_error "❌ Failed to navigate to Frontend directory"
    cleanup
    exit 1
}

print_status "📁 Navigated to Frontend directory"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_warning "📦 Installing npm dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        print_error "❌ Failed to install npm dependencies"
        cd ..
        cleanup
        exit 1
    fi
    print_status "✅ npm dependencies installed successfully!"
else
    print_status "✅ npm dependencies already installed!"
fi

# Start Vue development server
print_warning "🚀 Starting VueJS development server..."
print_info "🔗 Frontend will be available at: http://localhost:3000"
echo ""
echo -e "${YELLOW}=========================================${NC}"
print_status "🎉 Shravan Application is now running!"
print_info "📱 Backend API: http://localhost:5000"
print_info "🌐 Frontend App: http://localhost:3000"
echo -e "${YELLOW}=========================================${NC}"
echo ""
print_warning "Press Ctrl+C to stop the application"

# Start the development server (this will block until stopped)
npm run dev &
FRONTEND_PID=$!

# Wait for the frontend process to complete
wait $FRONTEND_PID

# Cleanup when done
cleanup