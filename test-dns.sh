#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Testing DNS Configuration${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Domains to test
DOMAINS=(
    "webhostingpracticenode.com"
    "webhostingpracticepython.com"
    "webhostingpracticestatic.com"
)

# Check /etc/hosts
echo -e "${BLUE}📋 Checking /etc/hosts configuration...${NC}"
echo ""
for domain in "${DOMAINS[@]}"; do
    if grep -q "$domain" /etc/hosts; then
        echo -e "${GREEN}✅ $domain found in /etc/hosts${NC}"
    else
        echo -e "${RED}❌ $domain NOT found in /etc/hosts${NC}"
        echo -e "${YELLOW}   Run: ./setup-dns-local.sh${NC}"
    fi
done

echo ""
echo -e "${BLUE}🔍 Testing DNS resolution...${NC}"
echo ""
for domain in "${DOMAINS[@]}"; do
    if ping -c 1 "$domain" &> /dev/null; then
        echo -e "${GREEN}✅ $domain resolves to 127.0.0.1${NC}"
    else
        echo -e "${RED}❌ $domain failed to resolve${NC}"
    fi
done

echo ""
echo -e "${BLUE}🌐 Testing HTTP responses...${NC}"
echo ""

for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}Testing $domain...${NC}"
    
    # Test with curl
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$domain" --max-time 5)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ $domain returned HTTP $HTTP_CODE${NC}"
    else
        echo -e "${RED}❌ $domain returned HTTP $HTTP_CODE${NC}"
    fi
    echo ""
done

echo -e "${BLUE}🐳 Checking Docker containers...${NC}"
echo ""
docker-compose ps

echo ""
echo -e "${BLUE}📊 Recent nginx access logs:${NC}"
echo ""
docker-compose logs --tail=10 nginx

echo ""
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Testing Complete${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${BLUE}💡 Tips:${NC}"
echo "  - Visit the domains in your browser"
echo "  - Check logs: docker-compose logs -f nginx"
echo "  - View /etc/hosts: cat /etc/hosts | grep webhostingpractice"
echo ""

