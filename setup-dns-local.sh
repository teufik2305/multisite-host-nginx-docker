#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up DNS-Based Routing...${NC}"
echo ""

# Define the domains
DOMAINS=(
    "webhostingpracticenode.com"
    "webhostingpracticepython.com"
    "webhostingpracticestatic.com"
)

# Check if domains already exist in /etc/hosts
NEEDS_UPDATE=false
for domain in "${DOMAINS[@]}"; do
    if ! grep -q "$domain" /etc/hosts; then
        NEEDS_UPDATE=true
        break
    fi
done

# Update /etc/hosts if needed
if [ "$NEEDS_UPDATE" = true ]; then
    echo -e "${YELLOW}Adding domains to /etc/hosts (requires sudo)...${NC}"
    
    # Backup /etc/hosts
    sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)
    
    # Add entries
    echo "" | sudo tee -a /etc/hosts > /dev/null
    echo "# Web Hosting Practice - Local DNS (added $(date))" | sudo tee -a /etc/hosts > /dev/null
    for domain in "${DOMAINS[@]}"; do
        echo "127.0.0.1  $domain" | sudo tee -a /etc/hosts > /dev/null
    done
    
    echo -e "${GREEN}✅ Domains added to /etc/hosts${NC}"
else
    echo -e "${GREEN}✅ Domains already in /etc/hosts${NC}"
fi

# Switch to DNS configuration
echo -e "${BLUE}Switching to DNS-based nginx configuration...${NC}"
[ -f "nginx/nginx.conf" ] && rm nginx/nginx.conf
cp nginx/nginx-dns.conf nginx/nginx.conf
echo -e "${GREEN}✅ DNS configuration active${NC}"

# Restart nginx
echo -e "${BLUE}Restarting nginx...${NC}"
docker-compose restart nginx > /dev/null 2>&1
echo -e "${GREEN}✅ Nginx restarted${NC}"

# Flush DNS cache
if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo dscacheutil -flushcache > /dev/null 2>&1
    sudo killall -HUP mDNSResponder > /dev/null 2>&1
fi

echo ""
echo -e "${GREEN}🎉 DNS-Based Routing Active!${NC}"
echo ""
echo -e "Access your apps:"
echo -e "  • ${BLUE}http://webhostingpracticenode.com${NC}"
echo -e "  • ${BLUE}http://webhostingpracticepython.com${NC}"
echo -e "  • ${BLUE}http://webhostingpracticestatic.com${NC}"
echo ""
