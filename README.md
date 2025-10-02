# Web Hosting Practice with Docker and Nginx

This project demonstrates how to host multiple applications using Docker and Nginx as a reverse proxy.

> 📚 **New to this project?** Start with the [Documentation Guide](docs/README.md) for a structured learning path!

## Project Structure

```
multisite-host-nginx-docker/
├── app1-node/          # Node.js application
├── app2-python/        # Python Flask application
├── app3-static/        # Static HTML website
├── nginx/              # Nginx reverse proxy configuration
├── docker-compose.yml  # Orchestrates all services
└── README.md
```

## What You'll Learn

1. **Containerization**: Each app runs in its own Docker container
2. **Reverse Proxy**: Nginx routes traffic to different apps based on the URL path or domain
3. **Service Orchestration**: Docker Compose manages multiple containers
4. **Networking**: Containers communicate through Docker networks
5. **Routing Modes**: Switch between path-based (`/app1`) and DNS-based (`app1.example.com`) routing

## Architecture Overview

```
Internet → Nginx (Port 80) → App1 (Node.js on port 3000)
                           → App2 (Python on port 5000)
                           → App3 (Static HTML)
```

- **http://localhost/app1** → Node.js application
- **http://localhost/app2** → Python Flask application
- **http://localhost/app3** → Static HTML site

## Quick Start

### Option 1: Easy Start Script
```bash
# Path-based routing (default)
./start.sh

# OR DNS-based routing
./start.sh dns
```

### Option 2: Manual Start
```bash
docker-compose up -d
```

### View logs:
```bash
docker-compose logs -f
```

### Stop all services:
```bash
docker-compose down
```

## Accessing the Applications

### Path-Based URLs (Default)
- Landing Page: http://localhost/
- App1 (Node.js): http://localhost/app1
- App2 (Python): http://localhost/app2
- App3 (Static): http://localhost/app3

### DNS-Based URLs (Optional - See docs/05-DNS_GUIDE.md)
Want to use real domain names locally?
```bash
./start.sh dns           # Switch to DNS mode
./setup-dns-local.sh     # Configure /etc/hosts
```

Then access via:
- App1: http://webhostingpracticenode.com
- App2: http://webhostingpracticepython.com
- App3: http://webhostingpracticestatic.com

See `docs/05-DNS_GUIDE.md` for complete DNS setup instructions!

## Key Concepts Explained

### Docker
- **Dockerfile**: Instructions to build a container image
- **Image**: Template for running containers
- **Container**: Running instance of an image

### Nginx Reverse Proxy
- Acts as a single entry point for all applications
- Routes requests based on URL path
- Can handle SSL, load balancing, and caching
- Isolates backend services from direct internet access

### Docker Compose
- Defines multi-container applications
- Manages networking between containers
- Simplifies starting/stopping entire stack

## Customization

### Adding a New App

1. Create app directory with Dockerfile
2. Add service to `docker-compose.yml`
3. Add location block to `nginx/nginx-path.conf` (or `nginx-dns.conf`)
4. Regenerate active config: `cp nginx/nginx-path.conf nginx/nginx.conf` (or `cp nginx/nginx-dns.conf nginx/nginx.conf`)

### Changing Ports

Edit the `ports` section in `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Change 8080 to your desired port
```

## Production Considerations

- **SSL/TLS**: Add HTTPS using Let's Encrypt
- **Environment Variables**: Use `.env` files for secrets
- **Health Checks**: Add health check endpoints
- **Logging**: Configure centralized logging
- **Security**: Run containers as non-root users
- **Resource Limits**: Set CPU and memory limits

## Troubleshooting

**Port already in use:**
```bash
# Change the port in docker-compose.yml or stop the conflicting service
lsof -i :80
```

**Container not starting:**
```bash
docker-compose logs [service-name]
```

**Reset everything:**
```bash
docker-compose down -v
docker-compose up -d --build
```

## 📚 Documentation

**Start here:**
1. `docs/01-LEARNING_GUIDE.md` - Step-by-step tutorials for beginners
2. `docs/02-ARCHITECTURE.md` - Understand how everything works
3. `docs/03-ROUTING_MODES.md` - Path-based vs DNS-based routing
4. `docs/04-DNS_VS_PATH.md` - Detailed comparison of routing modes
5. `docs/05-DNS_GUIDE.md` - Complete DNS setup guide
6. `docs/06-CHEATSHEET.md` - Quick command reference

**Recommended learning path:**
- Beginners: Start with `01-LEARNING_GUIDE.md`
- Advanced: Jump to `03-ROUTING_MODES.md` or `06-CHEATSHEET.md`