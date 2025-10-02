#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Switching to Path-Based Routing${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

echo -e "${BLUE}📋 This script will:${NC}"
echo "  1. Restore path-based nginx configuration"
echo "  2. Restart nginx container"
echo ""

# Check if path backup exists, otherwise use the default path config
if [ -f "nginx/nginx.conf.path-backup" ]; then
    echo -e "${BLUE}🔄 Restoring path-based configuration from backup...${NC}"
    cp nginx/nginx.conf.path-backup nginx/nginx.conf
    echo -e "${GREEN}✅ Restored from backup${NC}"
else
    echo -e "${BLUE}🔄 Checking current configuration...${NC}"
    
    # Check if current config is already path-based
    if grep -q "location /app1" nginx/nginx.conf && ! grep -q "webhostingpracticenode.com" nginx/nginx.conf; then
        echo -e "${GREEN}✅ Already using path-based configuration${NC}"
    else
        echo -e "${YELLOW}⚠️  No backup found, but nginx.conf should already be path-based${NC}"
        echo -e "${YELLOW}    Current nginx.conf will be used${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🔄 Restarting nginx container...${NC}"

# Restart nginx
if docker-compose restart nginx; then
    echo -e "${GREEN}✅ Nginx restarted successfully${NC}"
else
    echo -e "${RED}❌ Failed to restart nginx${NC}"
    echo -e "${YELLOW}    Try running: docker-compose up -d${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  ✅ Path-Based Routing Active!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${BLUE}🌐 Your applications are now accessible at:${NC}"
echo ""
echo -e "   ${GREEN}http://localhost/${NC}       - Landing page"
echo -e "   ${GREEN}http://localhost/app1${NC}  - Node.js + Express"
echo -e "   ${GREEN}http://localhost/app2${NC}  - Python + Flask"
echo -e "   ${GREEN}http://localhost/app3${NC}  - Static HTML"
echo ""
echo -e "${BLUE}📝 Want DNS-based routing?${NC}"
echo -e "   ${YELLOW}./setup-dns-local.sh${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"

