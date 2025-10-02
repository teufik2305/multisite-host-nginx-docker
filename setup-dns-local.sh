#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  DNS Setup for Local Testing${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo -e "${RED}❌ Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}📋 This script will:${NC}"
echo "  1. Backup your current /etc/hosts file"
echo "  2. Add local DNS entries for testing"
echo "  3. Switch to DNS-based nginx configuration"
echo "  4. Restart nginx container"
echo ""

# Define the domains
DOMAINS=(
    "webhostingpracticenode.com"
    "webhostingpracticepython.com"
    "webhostingpracticestatic.com"
)

# Check if domains already exist in /etc/hosts
echo -e "${BLUE}🔍 Checking current /etc/hosts...${NC}"
NEEDS_UPDATE=false
for domain in "${DOMAINS[@]}"; do
    if grep -q "$domain" /etc/hosts; then
        echo -e "${GREEN}✅ $domain already in /etc/hosts${NC}"
    else
        echo -e "${YELLOW}⚠️  $domain not found in /etc/hosts${NC}"
        NEEDS_UPDATE=true
    fi
done
echo ""

if [ "$NEEDS_UPDATE" = true ]; then
    echo -e "${YELLOW}⚠️  We need to update your /etc/hosts file${NC}"
    echo -e "${YELLOW}    This requires sudo (administrator) access${NC}"
    echo ""
    echo -e "${BLUE}The following will be added to /etc/hosts:${NC}"
    echo ""
    for domain in "${DOMAINS[@]}"; do
        echo "    127.0.0.1  $domain"
    done
    echo ""
    
    read -p "Do you want to proceed? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📝 Updating /etc/hosts...${NC}"
        
        # Backup /etc/hosts
        sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✅ Backup created${NC}"
        
        # Add entries
        echo "" | sudo tee -a /etc/hosts > /dev/null
        echo "# Web Hosting Practice - Local DNS (added $(date))" | sudo tee -a /etc/hosts > /dev/null
        for domain in "${DOMAINS[@]}"; do
            echo "127.0.0.1  $domain" | sudo tee -a /etc/hosts > /dev/null
            echo -e "${GREEN}✅ Added $domain${NC}"
        done
        
        echo -e "${GREEN}✅ /etc/hosts updated successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Skipping /etc/hosts update${NC}"
        echo -e "${YELLOW}    You'll need to add the domains manually${NC}"
    fi
else
    echo -e "${GREEN}✅ All domains already configured in /etc/hosts${NC}"
fi

echo ""
echo -e "${BLUE}🔄 Switching to DNS-based nginx configuration...${NC}"

# Check if nginx-dns.conf exists
if [ -f "nginx/nginx-dns.conf" ]; then
    # Backup current config (only if it's not already a backup)
    if [ -f "nginx/nginx.conf" ] && ! grep -q "webhostingpracticenode.com" nginx/nginx.conf; then
        cp nginx/nginx.conf nginx/nginx.conf.path-backup
        echo -e "${GREEN}✅ Backed up path-based nginx.conf${NC}"
    fi
    
    # Copy DNS config
    cp nginx/nginx-dns.conf nginx/nginx.conf
    echo -e "${GREEN}✅ Switched to DNS-based configuration${NC}"
else
    echo -e "${RED}❌ nginx/nginx-dns.conf not found${NC}"
    exit 1
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

# Flush DNS cache
echo ""
echo -e "${BLUE}🗑️  Flushing DNS cache...${NC}"
if [ "$OS" = "macOS" ]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo -e "${GREEN}✅ DNS cache flushed (macOS)${NC}"
elif [ "$OS" = "Linux" ]; then
    if command -v systemd-resolve &> /dev/null; then
        sudo systemd-resolve --flush-caches
        echo -e "${GREEN}✅ DNS cache flushed (Linux)${NC}"
    else
        echo -e "${YELLOW}⚠️  systemd-resolve not found, skipping cache flush${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  ✅ DNS Setup Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${BLUE}🌐 Your applications are now accessible at:${NC}"
echo ""
for domain in "${DOMAINS[@]}"; do
    echo -e "   ${GREEN}http://$domain${NC}"
done
echo ""
echo -e "${BLUE}🧪 Test with curl:${NC}"
echo ""
for domain in "${DOMAINS[@]}"; do
    echo -e "   ${YELLOW}curl -I http://$domain${NC}"
done
echo ""
echo -e "${BLUE}📝 Quick verification:${NC}"
echo -e "   ${YELLOW}cat /etc/hosts | grep webhostingpractice${NC}"
echo ""
echo -e "${BLUE}📚 For more info, see docs/05-DNS_GUIDE.md${NC}"
echo ""
echo -e "${GREEN}Happy testing! 🚀${NC}"

