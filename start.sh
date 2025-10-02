#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get routing mode from first argument (default: path)
MODE="${1:-path}"

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Web Hosting Practice Setup${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Validate mode argument
if [[ "$MODE" != "path" && "$MODE" != "dns" ]]; then
    echo -e "${RED}❌ Invalid mode: $MODE${NC}"
    echo -e "${YELLOW}Usage: $0 [path|dns]${NC}"
    echo ""
    echo -e "  ${BLUE}path${NC} - Path-based routing (localhost/app1, localhost/app2, etc.)"
    echo -e "  ${BLUE}dns${NC}  - DNS-based routing (webhostingpracticenode.com, etc.)"
    echo ""
    exit 1
fi

echo -e "${BLUE}📡 Routing Mode: ${GREEN}${MODE}${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker is not installed. Please install Docker Desktop first.${NC}"
    echo "   Visit: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed and running${NC}"
echo ""

# Setup nginx configuration based on mode
echo -e "${BLUE}📝 Setting up nginx configuration for ${MODE} mode...${NC}"
if [ "$MODE" = "dns" ]; then
    if [ -f "nginx/nginx-dns.conf" ]; then
        cp nginx/nginx-dns.conf nginx/nginx.conf
        echo -e "${GREEN}✅ nginx.conf configured for DNS-based routing${NC}"
    else
        echo -e "${RED}❌ nginx-dns.conf not found${NC}"
        exit 1
    fi
elif [ "$MODE" = "path" ]; then
    if [ -f "nginx/nginx-path.conf" ]; then
        cp nginx/nginx-path.conf nginx/nginx.conf
        echo -e "${GREEN}✅ nginx.conf configured for path-based routing${NC}"
    else
        echo -e "${RED}❌ nginx-path.conf not found${NC}"
        exit 1
    fi
fi

# Build and start containers
echo -e "${BLUE}🔨 Building and starting containers...${NC}"
docker-compose up -d --build

# Wait a moment for containers to be ready
echo ""
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 5

# Check container status
echo ""
echo -e "${BLUE}📊 Container Status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  ✅ Setup Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

if [ "$MODE" = "path" ]; then
    echo -e "${BLUE}🌐 Access your applications (PATH mode):${NC}"
    echo ""
    echo -e "   🏠 Home Page:      ${GREEN}http://localhost/${NC}"
    echo -e "   📦 App 1 (Node):   ${GREEN}http://localhost/app1${NC}"
    echo -e "   🐍 App 2 (Python): ${GREEN}http://localhost/app2${NC}"
    echo -e "   🌐 App 3 (Static): ${GREEN}http://localhost/app3${NC}"
    echo ""
elif [ "$MODE" = "dns" ]; then
    echo -e "${BLUE}🌐 Access your applications (DNS mode):${NC}"
    echo ""
    echo -e "   🏠 Home Page:      ${GREEN}http://localhost/${NC}"
    echo -e "   📦 App 1 (Node):   ${GREEN}http://webhostingpracticenode.com/${NC}"
    echo -e "   🐍 App 2 (Python): ${GREEN}http://webhostingpracticepython.com/${NC}"
    echo -e "   🌐 App 3 (Static): ${GREEN}http://webhostingpracticestatic.com/${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  DNS Setup Required:${NC}"
    echo -e "   Add these entries to /etc/hosts:"
    echo -e "   ${BLUE}127.0.0.1  webhostingpracticenode.com${NC}"
    echo -e "   ${BLUE}127.0.0.1  webhostingpracticepython.com${NC}"
    echo -e "   ${BLUE}127.0.0.1  webhostingpracticestatic.com${NC}"
    echo ""
    echo -e "   Quick setup: ${YELLOW}./setup-dns-local.sh${NC}"
    echo ""
fi

echo -e "${BLUE}📝 Useful commands:${NC}"
echo ""
echo -e "   View logs:         ${YELLOW}docker-compose logs -f${NC}"
echo -e "   Stop services:     ${YELLOW}docker-compose down${NC}"
echo -e "   Restart services:  ${YELLOW}docker-compose restart${NC}"
echo -e "   Rebuild:           ${YELLOW}docker-compose up -d --build${NC}"
echo -e "   Switch to PATH:    ${YELLOW}./start.sh path${NC}"
echo -e "   Switch to DNS:     ${YELLOW}./start.sh dns${NC}"
echo ""
echo -e "${BLUE}📚 Learning resources:${NC}"
echo -e "   - README.md for overview"
echo -e "   - docs/01-LEARNING_GUIDE.md for step-by-step tutorials"
echo ""
echo -e "${GREEN}Happy learning! 🚀${NC}"

