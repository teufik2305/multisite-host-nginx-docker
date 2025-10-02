# Docker & Nginx Cheat Sheet

Quick reference for common commands and concepts.

## 🚀 Getting Started

```bash
# Start everything
./start.sh
# OR
docker-compose up -d

# Stop everything
docker-compose down

# View status
docker-compose ps
```

## 📦 Docker Commands

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start a container
docker start <container-name>

# Stop a container
docker stop <container-name>

# Restart a container
docker restart <container-name>

# Remove a container
docker rm <container-name>

# Remove all stopped containers
docker container prune
```

### Image Management
```bash
# List images
docker images

# Build an image
docker build -t <image-name> <path>

# Remove an image
docker rmi <image-name>

# Remove unused images
docker image prune -a
```

### Logs and Debugging
```bash
# View container logs
docker logs <container-name>

# Follow logs (live)
docker logs -f <container-name>

# View last 50 lines
docker logs --tail 50 <container-name>

# Enter container shell
docker exec -it <container-name> sh

# View container processes
docker top <container-name>

# Inspect container
docker inspect <container-name>
```

### Resource Monitoring
```bash
# View resource usage
docker stats

# View resource usage for specific container
docker stats <container-name>
```

## 🎼 Docker Compose Commands

### Basic Operations
```bash
# Start services (in background)
docker-compose up -d

# Start and rebuild images
docker-compose up -d --build

# Stop services (keeps containers)
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes
docker-compose down -v

# View service status
docker-compose ps
```

### Service-Specific Operations
```bash
# Restart specific service
docker-compose restart <service-name>

# Rebuild specific service
docker-compose up -d --build <service-name>

# View logs for specific service
docker-compose logs <service-name>

# Scale a service
docker-compose up -d --scale <service-name>=3
```

### Logs
```bash
# View all logs
docker-compose logs

# Follow logs (live)
docker-compose logs -f

# Logs for specific service
docker-compose logs -f <service-name>

# Last 100 lines
docker-compose logs --tail=100
```

### Troubleshooting
```bash
# Validate compose file
docker-compose config

# List running services
docker-compose ps

# View service details
docker-compose ps <service-name>
```

## 🌐 Nginx Commands

### Inside Container
```bash
# Enter nginx container
docker exec -it nginx-proxy sh

# Test configuration
nginx -t

# Reload configuration (without restart)
nginx -s reload

# View nginx version
nginx -v
```

### Configuration Testing
```bash
# Test config from outside container
docker exec nginx-proxy nginx -t

# Reload nginx
docker exec nginx-proxy nginx -s reload
```

### Logs
```bash
# Access logs
docker exec nginx-proxy tail -f /var/log/nginx/access.log

# Error logs
docker exec nginx-proxy tail -f /var/log/nginx/error.log
```

## 🔍 Debugging Workflow

### When Something Doesn't Work

**Step 1: Check Container Status**
```bash
docker-compose ps
```

**Step 2: Check Logs**
```bash
docker-compose logs <service-name>
```

**Step 3: Test Connectivity**
```bash
# Test if service is responding
docker exec nginx-proxy wget -O- http://app1:3000

# Check if port is listening
docker exec app1-node netstat -tuln | grep 3000
```

**Step 4: Restart Service**
```bash
docker-compose restart <service-name>
```

**Step 5: Rebuild if Needed**
```bash
docker-compose up -d --build <service-name>
```

## 🔧 Common Issues & Solutions

### Port Already in Use
```bash
# Find what's using the port
lsof -i :80

# Kill the process
kill -9 <PID>

# OR change port in docker-compose.yml
ports:
  - "8080:80"
```

### Container Won't Start
```bash
# Check logs
docker-compose logs <service-name>

# Remove and recreate
docker-compose up -d --force-recreate <service-name>
```

### Changes Not Reflected
```bash
# Rebuild without cache
docker-compose build --no-cache <service-name>
docker-compose up -d <service-name>
```

### Network Issues
```bash
# Recreate network
docker-compose down
docker-compose up -d
```

### Clean Slate
```bash
# Nuclear option: remove everything
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

## 📝 nginx.conf Syntax

### Location Blocks
```nginx
# Exact match
location = /app1 { }

# Prefix match
location /app1 { }

# Regular expression (case-sensitive)
location ~ \.php$ { }

# Regular expression (case-insensitive)
location ~* \.(jpg|png)$ { }
```

### Proxy Configuration
```nginx
location /app1 {
    # Forward to backend
    proxy_pass http://app1:3000/;
    
    # Headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

### Upstream (Load Balancing)
```nginx
upstream backend {
    server app1:3000;
    server app2:3000;
    server app3:3000;
}

location / {
    proxy_pass http://backend;
}
```

## 🐳 Dockerfile Syntax

### Common Instructions
```dockerfile
# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy files
COPY package.json .
COPY . .

# Run commands during build
RUN npm install

# Set environment variables
ENV NODE_ENV=production

# Expose port (documentation only)
EXPOSE 3000

# Default command when container starts
CMD ["node", "server.js"]

# Alternative: ENTRYPOINT
ENTRYPOINT ["node"]
CMD ["server.js"]
```

### Multi-Stage Builds
```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/server.js"]
```

## 📋 docker-compose.yml Syntax

### Service Definition
```yaml
services:
  app1:
    # Build from Dockerfile
    build: ./app1
    
    # OR use existing image
    image: nginx:alpine
    
    # Container name
    container_name: app1-node
    
    # Port mapping (host:container)
    ports:
      - "3000:3000"
    
    # Expose port (internal only)
    expose:
      - "3000"
    
    # Environment variables
    environment:
      - NODE_ENV=production
      - DEBUG=false
    
    # Volumes
    volumes:
      - ./data:/app/data
      - app-cache:/app/cache
    
    # Networks
    networks:
      - webnet
    
    # Dependencies
    depends_on:
      - database
    
    # Restart policy
    restart: unless-stopped
    
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## 🌐 Networking

### Test Connectivity Between Containers
```bash
# From one container to another
docker exec app1-node ping app2

# HTTP request
docker exec app1-node wget -O- http://app2:5000

# DNS lookup
docker exec app1-node nslookup app2
```

### Inspect Network
```bash
# List networks
docker network ls

# Inspect specific network
docker network inspect <network-name>
```

## 💾 Volumes

### Volume Commands
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect <volume-name>

# Remove volume
docker volume rm <volume-name>

# Remove all unused volumes
docker volume prune
```

### In docker-compose.yml
```yaml
services:
  app:
    volumes:
      # Named volume
      - db-data:/var/lib/postgresql/data
      
      # Bind mount (host:container)
      - ./config:/app/config
      
      # Anonymous volume
      - /app/node_modules

volumes:
  db-data:
```

## 🔐 Environment Variables

### Set in docker-compose.yml
```yaml
services:
  app:
    environment:
      - API_KEY=secret123
      - NODE_ENV=production
    
    # OR from .env file
    env_file:
      - .env
```

### Access in Application
```javascript
// Node.js
const apiKey = process.env.API_KEY;

# Python
import os
api_key = os.getenv('API_KEY')
```

## 📊 Health Checks

### In docker-compose.yml
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s      # Check every 30 seconds
  timeout: 10s       # Timeout after 10 seconds
  retries: 3         # Try 3 times before marking unhealthy
  start_period: 40s  # Grace period on startup
```

### Check Health Status
```bash
docker ps
# Look for "healthy" or "unhealthy" in STATUS column

docker inspect --format='{{.State.Health.Status}}' <container-name>
```

## 🎯 Best Practices

### Development
- ✅ Use `docker-compose` for local development
- ✅ Mount code as volumes for hot-reload
- ✅ Use `.dockerignore` to exclude files
- ✅ Tag images with versions
- ✅ Use specific base image versions

### Production
- ✅ Use multi-stage builds
- ✅ Run containers as non-root user
- ✅ Set resource limits
- ✅ Use health checks
- ✅ Use secrets management
- ✅ Enable logging
- ✅ Use orchestration (Kubernetes, ECS)

## 🔗 Useful URLs (After Starting)

- 🏠 Home: http://localhost/
- 📦 App 1: http://localhost/app1
- 🐍 App 2: http://localhost/app2
- 🌐 App 3: http://localhost/app3
- 💚 Health: http://localhost/health

## 📚 Quick References

### This Project's Services
- `nginx` - Reverse proxy (port 80)
- `app1` - Node.js app (port 3000)
- `app2` - Python app (port 5000)
- `app3` - Static site (port 80)

### Network
- Network name: `webnet`
- Driver: bridge
- Internal DNS: service names resolve to IPs

### Important Files
- `docker-compose.yml` - Service definitions
- `nginx/nginx.conf` - Routing rules
- `*/Dockerfile` - Container build instructions

## 🆘 Emergency Commands

```bash
# Stop everything immediately
docker-compose kill

# Remove everything (DANGEROUS)
docker-compose down -v
docker system prune -a

# Export container as image (backup)
docker commit <container-name> backup-image

# View Docker disk usage
docker system df

# Clean up everything
docker system prune -a --volumes
```

## 📖 Learn More

- Docker Docs: https://docs.docker.com
- Nginx Docs: https://nginx.org/en/docs/
- Docker Compose: https://docs.docker.com/compose/
- This Project: See `LEARNING_GUIDE.md`

