#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Path-Based Routing...${NC}"
echo ""

# Check if nginx-path.conf exists
if [ ! -f "nginx/nginx-path.conf" ]; then
    echo -e "${RED}❌ nginx-path.conf not found${NC}"
    exit 1
fi

# Switch to path configuration
echo -e "${BLUE}Switching to path-based nginx configuration...${NC}"
[ -f "nginx/nginx.conf" ] && rm nginx/nginx.conf
cp nginx/nginx-path.conf nginx/nginx.conf
echo -e "${GREEN}✅ Path configuration active${NC}"

# Restart nginx
echo -e "${BLUE}Restarting nginx...${NC}"
docker-compose restart nginx > /dev/null 2>&1
echo -e "${GREEN}✅ Nginx restarted${NC}"

echo ""
echo -e "${GREEN}🎉 Path-Based Routing Active!${NC}"
echo ""
echo -e "Access your apps:"
echo -e "  • ${BLUE}http://localhost/${NC}       - Landing page"
echo -e "  • ${BLUE}http://localhost/app1/${NC}  - Node.js"
echo -e "  • ${BLUE}http://localhost/app2/${NC}  - Python"
echo -e "  • ${BLUE}http://localhost/app3/${NC}  - Static"
echo ""
