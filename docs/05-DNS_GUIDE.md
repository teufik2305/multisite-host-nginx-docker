# DNS-Based Routing Guide

## Overview

Instead of routing by URL path (`/app1`, `/app2`), we'll route by domain name:
- `webhostingpracticenode.com` → App 1 (Node.js)
- `webhostingpracticepython.com` → App 2 (Python)
- `webhostingpracticestatic.com` → App 3 (Static)

## How DNS Works with Docker & Nginx

```
┌─────────────────────────────────────────────────────────────────┐
│                        User's Browser                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ 1. DNS Lookup
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DNS Server                               │
│  webhostingpracticenode.com     → YOUR_SERVER_IP                │
│  webhostingpracticepython.com   → YOUR_SERVER_IP                │
│  webhostingpracticestatic.com   → YOUR_SERVER_IP                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ 2. HTTP Request with Host header
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Your Server (Port 80/443)                   │
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Nginx Reverse Proxy                     │ │
│  │                                                            │ │
│  │  Reads "Host" header to determine which app to route to:   │ │
│  │                                                            │ │
│  │  server_name webhostingpracticenode.com                    │ │
│  │    → proxy_pass to app1:3000                               │ │
│  │                                                            │ │
│  │  server_name webhostingpracticepython.com                  │ │
│  │    → proxy_pass to app2:5000                               │ │
│  │                                                            │ │
│  │  server_name webhostingpracticestatic.com                  │ │
│  │    → proxy_pass to app3:80                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                    │              │              │              │
│       ┌────────────┘              │              └────────────┐ │
│       ▼                           ▼                           ▼ │
│  ┌─────────┐              ┌──────────┐              ┌─────────┐ │
│  │  App1   │              │  App2    │              │  App3   │ │
│  │ Node.js │              │  Python  │              │  Static │ │
│  └─────────┘              └──────────┘              └─────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Setup

### Step 1: Update Nginx Configuration

We need to create separate `server` blocks for each domain instead of using location paths.

See: `nginx/nginx-dns.conf` (I'll create this for you)

### Step 2: Local Testing with /etc/hosts

For local testing (without buying domains), we can fake DNS by editing `/etc/hosts`:

```bash
# Edit hosts file (requires sudo)
sudo nano /etc/hosts

# Add these lines:
127.0.0.1  webhostingpracticenode.com
127.0.0.1  webhostingpracticepython.com
127.0.0.1  webhostingpracticestatic.com
```

### Step 3: Production DNS Setup

In production, you'd configure DNS records at your domain registrar:

```
Type    Name                          Value           TTL
--------------------------------------------------------------
A       webhostingpracticenode.com    203.0.113.10    3600
A       webhostingpracticepython.com  203.0.113.10    3600
A       webhostingpracticestatic.com  203.0.113.10    3600
```

All domains point to the SAME IP address (your server). Nginx differentiates them by the `Host` header.

## DNS Flow Explained

### 1. User Types Domain
```
User enters: http://webhostingpracticenode.com
```

### 2. DNS Resolution
```
Browser asks DNS: "What's the IP for webhostingpracticenode.com?"
DNS responds: "203.0.113.10" (your server's IP)
```

### 3. HTTP Request
```
Browser sends HTTP request to 203.0.113.10:80
Request includes header: Host: webhostingpracticenode.com
```

### 4. Nginx Routes Request
```
Nginx reads Host header: "webhostingpracticenode.com"
Nginx finds matching server block
Nginx forwards to app1:3000
```

### 5. Response
```
App1 processes request
Response flows back through nginx to browser
```

## Configuration Differences

### Old Way (Path-Based Routing)
```nginx
# ONE server block handles all domains
server {
    listen 80;
    server_name localhost;
    
    location /app1 { proxy_pass http://app1:3000/; }
    location /app2 { proxy_pass http://app2:5000/; }
    location /app3 { proxy_pass http://app3:80/; }
}
```

### New Way (Domain-Based Routing)
```nginx
# SEPARATE server blocks for each domain
server {
    listen 80;
    server_name webhostingpracticenode.com;
    location / { proxy_pass http://app1:3000/; }
}

server {
    listen 80;
    server_name webhostingpracticepython.com;
    location / { proxy_pass http://app2:5000/; }
}

server {
    listen 80;
    server_name webhostingpracticestatic.com;
    location / { proxy_pass http://app3:80/; }
}
```

## Advantages of Domain-Based Routing

✅ **Clean URLs**: `webhostingpracticenode.com` instead of `localhost/app1`  
✅ **Separate SSL Certificates**: Each domain can have its own certificate  
✅ **Independent Scaling**: Easier to move apps to different servers  
✅ **Professional**: How real production systems work  
✅ **SEO Friendly**: Better for search engine optimization  

## Wildcard Domains

You can also use subdomains:

```
node.webhostingpractice.com
python.webhostingpractice.com
static.webhostingpractice.com
```

DNS Configuration:
```
Type    Name        Value           TTL
------------------------------------------
A       @           203.0.113.10    3600
CNAME   node        @               3600
CNAME   python      @               3600
CNAME   static      @               3600
```

Or use wildcard:
```
Type    Name    Value           TTL
--------------------------------------
A       @       203.0.113.10    3600
A       *       203.0.113.10    3600
```

Nginx with wildcard:
```nginx
server {
    listen 80;
    server_name ~^(?<subdomain>.+)\.webhostingpractice\.com$;
    
    location / {
        proxy_pass http://$subdomain:3000;
    }
}
```

## Testing Your Setup

### Local Testing (with /etc/hosts)

```bash
# Quick setup (recommended)
./start.sh dns           # Switch to DNS mode
./setup-dns-local.sh     # Configure /etc/hosts

# Manual setup
# 1. Update /etc/hosts
sudo nano /etc/hosts
# Add the domain mappings

# 2. Update nginx configuration
./start.sh dns
# OR manually: cp nginx/nginx-dns.conf nginx/nginx.conf && docker-compose restart nginx

# 3. Test in browser
# Visit: http://webhostingpracticenode.com
# Visit: http://webhostingpracticepython.com
# Visit: http://webhostingpracticestatic.com

# 4. Test with curl
curl -H "Host: webhostingpracticenode.com" http://localhost
curl -H "Host: webhostingpracticepython.com" http://localhost
curl -H "Host: webhostingpracticestatic.com" http://localhost
```

### Production Testing

```bash
# Check DNS resolution
dig webhostingpracticenode.com
nslookup webhostingpracticenode.com

# Test HTTP
curl -I http://webhostingpracticenode.com

# Test HTTPS
curl -I https://webhostingpracticenode.com
```

## SSL/HTTPS with Multiple Domains

### Using Let's Encrypt (Certbot)

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificates for all domains
sudo certbot --nginx \
  -d webhostingpracticenode.com \
  -d webhostingpracticepython.com \
  -d webhostingpracticestatic.com

# Certbot will automatically update nginx config
```

### Using Wildcard Certificate

```bash
# For *.webhostingpractice.com
sudo certbot certonly --manual \
  --preferred-challenges=dns \
  -d *.webhostingpractice.com \
  -d webhostingpractice.com
```

### Manual SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name webhostingpracticenode.com;
    
    ssl_certificate /etc/letsencrypt/live/webhostingpracticenode.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/webhostingpracticenode.com/privkey.pem;
    
    location / {
        proxy_pass http://app1:3000/;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name webhostingpracticenode.com;
    return 301 https://$server_name$request_uri;
}
```

## Real-World DNS Providers

### Popular DNS Providers
- **Cloudflare** (recommended - free, fast, DDoS protection)
- **AWS Route 53** (enterprise-grade)
- **Google Cloud DNS**
- **Namecheap** (domain + DNS)
- **GoDaddy** (domain + DNS)

### Cloudflare Example Setup

1. **Buy domains** at any registrar (Namecheap, GoDaddy, etc.)

2. **Add site to Cloudflare**
   - Sign up at cloudflare.com
   - Add your domain
   - Cloudflare gives you nameservers

3. **Update nameservers** at your registrar
   ```
   NS1: zara.ns.cloudflare.com
   NS2: walt.ns.cloudflare.com
   ```

4. **Add DNS records** in Cloudflare dashboard
   ```
   Type: A
   Name: webhostingpracticenode.com
   Content: YOUR_SERVER_IP
   Proxy: Enabled (orange cloud)
   
   Type: A
   Name: webhostingpracticepython.com
   Content: YOUR_SERVER_IP
   Proxy: Enabled
   
   Type: A
   Name: webhostingpracticestatic.com
   Content: YOUR_SERVER_IP
   Proxy: Enabled
   ```

5. **Cloudflare handles SSL automatically!**

## Docker Compose with DNS

No changes needed to `docker-compose.yml`! The DNS resolution happens BEFORE the request reaches Docker.

## Common Issues

### Issue 1: Domain not resolving
```bash
# Check DNS propagation
dig webhostingpracticenode.com

# Check if /etc/hosts is correct (local testing)
cat /etc/hosts | grep webhostingpractice

# Flush DNS cache
# macOS:
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Linux:
sudo systemd-resolve --flush-caches

# Windows:
ipconfig /flushdns
```

### Issue 2: Nginx not routing correctly
```bash
# Test nginx config
docker exec nginx-proxy nginx -t

# Check which server block is matched
docker exec nginx-proxy nginx -T | grep server_name

# Test with curl
curl -v -H "Host: webhostingpracticenode.com" http://localhost
```

### Issue 3: Mixed content (HTTP/HTTPS)
```nginx
# Add these headers to force HTTPS
add_header Strict-Transport-Security "max-age=31536000" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
```

## Cost Considerations

### Domain Names
- `.com` domains: ~$10-15/year
- `.io` domains: ~$30-50/year
- `.dev` domains: ~$12-15/year (requires HTTPS)

### DNS Hosting
- Cloudflare: Free (for basic DNS)
- AWS Route 53: $0.50/month per hosted zone + $0.40 per million queries
- Google Cloud DNS: $0.20 per million queries

### Server
- DigitalOcean: $5-6/month (1GB RAM)
- AWS EC2: $5-10/month (t3.micro)
- Linode: $5/month (1GB RAM)

## Next Steps

1. ✅ I'll create the DNS-based nginx configuration
2. ✅ Set up local testing with /etc/hosts
3. ✅ Test all three domains locally
4. ⏭️ (Optional) Buy real domains and deploy to cloud
5. ⏭️ (Optional) Set up SSL certificates

Ready to try it out?

