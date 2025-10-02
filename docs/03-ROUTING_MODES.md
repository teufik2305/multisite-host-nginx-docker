# Routing Modes - Quick Reference

This project supports **two routing modes** that you can easily switch between.

## 🔀 Two Routing Modes

### 1. Path-Based Routing (Default)
**Best for:** Development, learning, local testing

**Access via:**
- http://localhost/ (landing page)
- http://localhost/app1 (Node.js)
- http://localhost/app2 (Python)
- http://localhost/app3 (Static)

**Features:**
- ✅ No DNS setup required
- ✅ Single domain (localhost)
- ✅ Easy to understand
- ✅ Perfect for beginners

---

### 2. DNS-Based Routing
**Best for:** Production-like setup, professional URLs

**Access via:**
- http://webhostingpracticenode.com
- http://webhostingpracticepython.com
- http://webhostingpracticestatic.com

**Features:**
- ✅ Clean, professional URLs
- ✅ Separate domains per app
- ✅ Production-style routing
- ✅ Independent SSL certificates (in production)

---

## 🔄 Switching Between Modes

### Switch to DNS-Based Routing
```bash
./setup-dns-local.sh
```
This will:
1. Add domains to `/etc/hosts` (requires sudo)
2. Copy `nginx-dns.conf` to `nginx.conf`
3. Restart nginx
4. Flush DNS cache

### Switch to Path-Based Routing
```bash
./setup-path-local.sh
```
This will:
1. Copy `nginx-path.conf` to `nginx.conf`
2. Restart nginx

**Note:** Both scripts are now streamlined and provide cleaner output.

---

## 📂 Configuration Files

| File | Purpose |
|------|---------|
| `nginx/nginx.conf` | **Active configuration** (generated, not in git) |
| `nginx/nginx-dns.conf` | DNS-based routing template (source) |
| `nginx/nginx-path.conf` | Path-based routing template (source) |
| `nginx/landing-page-path.html` | Landing page for path-based mode |
| `nginx/landing-page-dns.html` | Landing page for DNS-based mode |

**Note:** `nginx.conf` is automatically generated from either `nginx-path.conf` or `nginx-dns.conf` depending on which mode you activate. It's excluded from git via `.gitignore`.

---

## 🧪 Testing Your Setup

### Test Path-Based Mode
```bash
curl http://localhost/app1
curl http://localhost/app2
curl http://localhost/app3
```

### Test DNS-Based Mode
```bash
curl http://webhostingpracticenode.com
curl http://webhostingpracticepython.com
curl http://webhostingpracticestatic.com
```

Or run the test script:
```bash
./test-dns.sh
```

---

## 📝 Quick Start

**First time setup:**
```bash
# Start with path-based routing (default)
./start.sh

# Visit http://localhost/
```

**Try DNS-based routing:**
```bash
# Switch to DNS mode
./setup-dns-local.sh

# Visit http://webhostingpracticenode.com
```

**Switch back:**
```bash
# Return to path-based mode
./setup-path-local.sh

# Visit http://localhost/app1
```

---

## 🔍 Understanding the Differences

### Path-Based (nginx.conf)
```nginx
server {
    listen 80;
    server_name localhost;
    
    location /app1 { proxy_pass http://app1:3000/; }
    location /app2 { proxy_pass http://app2:5000/; }
    location /app3 { proxy_pass http://app3:80/; }
}
```

### DNS-Based (nginx-dns.conf)
```nginx
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

---

## 🆘 Troubleshooting

### DNS domains not working?
```bash
# Check /etc/hosts
cat /etc/hosts | grep webhostingpractice

# Run setup again
./setup-dns-local.sh
```

### Apps not loading?
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs nginx

# Restart everything
docker-compose restart
```

### Wrong mode active?
```bash
# Check which config is active
grep -E "location /app1|webhostingpracticenode" nginx/nginx.conf

# Switch to desired mode
./setup-path-local.sh    # or
./setup-dns-local.sh
```

### Missing nginx.conf?
The `nginx.conf` file is now generated automatically. If it's missing:
```bash
# The start.sh script will create it automatically
./start.sh

# Or manually copy the path-based config (default)
cp nginx/nginx-path.conf nginx/nginx.conf
```

---

## 📚 Related Documentation

- **../README.md** - Project overview and quick start
- **05-DNS_GUIDE.md** - Complete DNS routing guide
- **04-DNS_VS_PATH.md** - Detailed comparison
- **01-LEARNING_GUIDE.md** - Step-by-step tutorials
- **06-CHEATSHEET.md** - Command reference

---

## 💡 Tips

1. **Start with path-based** routing to learn the basics
2. **Try DNS-based** when you want a production-like setup
3. **Switch freely** between modes - they both work with the same apps
4. **Check the landing page** - it shows which mode is active
5. **Read the docs** - 04-DNS_VS_PATH.md has detailed comparisons

---

## 🎉 Recent Improvements

### Seamless Mode Switching
The apps now intelligently adapt to both routing modes:

- **App 1 (Node.js)**: Uses relative URLs (`api/hello` instead of `/app1/api/hello`)
- **App 2 (Python)**: Detects hostname and adjusts API paths dynamically
- **App 3 (Static)**: Dynamic `<base href>` that adapts based on routing mode

This means you can switch between path-based and DNS-based routing without modifying the applications themselves!

### Simplified Setup Scripts
- `setup-dns-local.sh` - Streamlined with cleaner output
- `setup-path-local.sh` - Quick and simple mode switching
- `start.sh` - Now ensures `nginx.conf` exists before starting

### Better Configuration Management
- `nginx.conf` is now auto-generated and excluded from git
- Template-based approach with `nginx-path.conf` and `nginx-dns.conf`
- No more manual backup files to manage

Happy coding! 🚀

