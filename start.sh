#!/bin/bash

# Dealer Partner Application - Startup Script
# Usage: ./start.sh [dev|prod]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Dealer Partner Application${NC}"
echo "=============================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Please do not run as root${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Development mode
if [ "$1" = "dev" ]; then
    echo -e "${YELLOW}📦 Starting in development mode...${NC}"
    
    # Check Flutter
    if ! command_exists flutter; then
        echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
        exit 1
    fi
    
    # Build Flutter Web
    echo -e "${YELLOW}Building Flutter Web...${NC}"
    cd HACKATON
    flutter pub get
    flutter build web --release
    cd ..
    
    # Check Dart
    if ! command_exists dart; then
        echo -e "${RED}❌ Dart not found. Please install Dart SDK first.${NC}"
        exit 1
    fi
    
    # Build Backend
    echo -e "${YELLOW}Building Backend...${NC}"
    cd backend
    dart pub get
    dart compile exe bin/server.dart -o bin/server
    cd ..
    
    # Start backend
    echo -e "${GREEN}✅ Starting backend server...${NC}"
    cd backend
    dart run bin/server.dart --host localhost --port 8080
    
# Production mode (default)
elif [ "$1" = "prod" ] || [ -z "$1" ]; then
    echo -e "${YELLOW}📦 Starting in production mode...${NC}"
    
    # Check if Docker is available
    if command_exists docker && command_exists docker-compose; then
        echo -e "${GREEN}✅ Docker found, building...${NC}"
        docker-compose up -d --build
        echo -e "${GREEN}✅ Application started!${NC}"
        echo ""
        echo "Access the application at: http://localhost"
        echo "API available at: http://localhost:8080/api"
        echo ""
        echo "View logs: docker-compose logs -f"
        echo "Stop: docker-compose down"
    else
        echo -e "${RED}❌ Docker not found. Please install Docker or use manual deployment.${NC}"
        echo ""
        echo "See DEPLOYMENT.md for manual installation instructions."
        exit 1
    fi
else
    echo "Usage: $0 [dev|prod]"
    echo ""
    echo "  dev  - Development mode (builds and runs locally)"
    echo "  prod - Production mode (uses Docker)"
    exit 1
fi
