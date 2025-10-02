#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Web Hosting Practice Setup${NC}"
echo -e "${BLUE}=================================${NC}"
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
echo -e "${BLUE}🌐 Access your applications:${NC}"
echo ""
echo -e "   🏠 Home Page:      ${GREEN}http://localhost/${NC}"
echo -e "   📦 App 1 (Node):   ${GREEN}http://localhost/app1${NC}"
echo -e "   🐍 App 2 (Python): ${GREEN}http://localhost/app2${NC}"
echo -e "   🌐 App 3 (Static): ${GREEN}http://localhost/app3${NC}"
echo ""
echo -e "${BLUE}📝 Useful commands:${NC}"
echo ""
echo -e "   View logs:         ${YELLOW}docker-compose logs -f${NC}"
echo -e "   Stop services:     ${YELLOW}docker-compose down${NC}"
echo -e "   Restart services:  ${YELLOW}docker-compose restart${NC}"
echo -e "   Rebuild:           ${YELLOW}docker-compose up -d --build${NC}"
echo ""
echo -e "${BLUE}📚 Learning resources:${NC}"
echo -e "   - README.md for overview"
echo -e "   - docs/01-LEARNING_GUIDE.md for step-by-step tutorials"
echo ""
echo -e "${GREEN}Happy learning! 🚀${NC}"

