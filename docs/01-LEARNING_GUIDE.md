# Learning Guide: Web Hosting with Docker and Nginx

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Core Concepts](#core-concepts)
3. [Step-by-Step Tutorial](#step-by-step-tutorial)
4. [Exercises](#exercises)
5. [Common Issues](#common-issues)
6. [Next Steps](#next-steps)

## Prerequisites

### Required Software
- Docker Desktop (includes Docker Compose)
- Text editor (VS Code recommended)
- Terminal/Command line access

### Installation Check
```bash
# Check Docker
docker --version

# Check Docker Compose
docker-compose --version

# Test Docker
docker run hello-world
```

## Core Concepts

### 1. Docker Containers
**What**: Isolated environments that run applications
**Why**: Consistent environments across different machines
**How**: Defined by Dockerfiles

### 2. Docker Images
**What**: Templates for creating containers
**Why**: Reusable, shareable application packages
**How**: Built from Dockerfiles

### 3. Nginx Reverse Proxy
**What**: Server that forwards requests to other servers
**Why**: Single entry point, load balancing, SSL termination
**How**: Configured via nginx.conf

### 4. Docker Compose
**What**: Tool for running multi-container applications
**Why**: Simplifies complex setups
**How**: Defined in docker-compose.yml

## Step-by-Step Tutorial

### Phase 1: Understanding the Setup

#### Step 1: Examine the Project Structure
```bash
cd /Users/teufik/multisite-host-nginx-docker
tree -L 2
```

**What to notice:**
- Each app has its own directory
- Each app has a Dockerfile
- Nginx has its own configuration
- docker-compose.yml ties everything together

#### Step 2: Read Through a Dockerfile
Open `app1-node/Dockerfile` and understand each line:

```dockerfile
FROM node:18-alpine        # Base image
WORKDIR /app               # Working directory
COPY package*.json ./      # Copy dependency files
RUN npm install           # Install dependencies
COPY . .                   # Copy application code
EXPOSE 3000                # Document the port
CMD ["node", "server.js"]  # Start command
```

**Try this:** Change the Node version to `node:20-alpine` and rebuild.

#### Step 3: Understand Nginx Configuration
Open `nginx/nginx-path.conf` (the path-based routing template) and find:

```nginx
location /app1 {
    proxy_pass http://app1_backend/;
    # Headers for proper proxying
}
```

**What this means:**
- Requests to `/app1` → forwarded to `app1:3000`
- `app1` is the service name from docker-compose.yml
- Docker's internal DNS resolves service names

**Note:** `nginx.conf` is auto-generated from either `nginx-path.conf` or `nginx-dns.conf` depending on which routing mode you choose.

### Phase 2: Running the Stack

#### Step 4: Start Everything
```bash
docker-compose up -d
```

**What happens:**
1. Docker builds images for each app (if not already built)
2. Creates a network for inter-container communication
3. Starts all containers
4. Nginx waits for other containers to be ready

#### Step 5: Verify Containers Are Running
```bash
docker-compose ps
```

You should see 4 containers running:
- nginx-proxy
- app1-node
- app2-python
- app3-static

#### Step 6: Check Logs
```bash
# All logs
docker-compose logs

# Specific service
docker-compose logs nginx

# Follow logs live
docker-compose logs -f app1
```

#### Step 7: Test the Applications
Open your browser and visit:
- http://localhost (landing page)
- http://localhost/app1 (Node.js)
- http://localhost/app2 (Python)
- http://localhost/app3 (Static)

### Phase 3: Making Changes

#### Step 8: Modify an Application
Edit `app1-node/server.js` and add a new endpoint:

```javascript
app.get('/api/custom', (req, res) => {
    res.json({ message: 'My custom endpoint!' });
});
```

#### Step 9: Rebuild and Restart
```bash
# Rebuild just app1
docker-compose up -d --build app1

# Or rebuild everything
docker-compose up -d --build
```

#### Step 10: Test Your Change
Visit: http://localhost/app1/api/custom

### Phase 4: Understanding Networking

#### Step 11: Inspect the Network
```bash
# List networks
docker network ls

# Inspect the web hosting network
docker network inspect multisite-host-nginx-docker_webnet
```

**What to notice:**
- All containers are on the same network
- Each has an IP address
- They can communicate using service names

#### Step 12: Test Inter-Container Communication
```bash
# Enter app1 container
docker exec -it app1-node sh

# Try to reach app2 (inside the container)
wget -O- http://app2:5000/api/status

# Exit
exit
```

### Phase 5: Advanced Configuration

#### Step 13: Add a New App
Create `app4-golang/`:

```bash
mkdir -p app4-golang
cd app4-golang
```

Create `Dockerfile`:
```dockerfile
FROM golang:1.21-alpine
WORKDIR /app
COPY . .
RUN go build -o main .
EXPOSE 8080
CMD ["./main"]
```

Create `main.go`:
```go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from Go!")
    })
    http.ListenAndServe(":8080", nil)
}
```

#### Step 14: Update docker-compose.yml
Add the new service:
```yaml
  app4:
    build: ./app4-golang
    container_name: app4-golang
    expose:
      - "8080"
    networks:
      - webnet
    restart: unless-stopped
```

#### Step 15: Update Nginx Configuration
Add to `nginx/nginx-path.conf`:
```nginx
upstream app4_backend {
    server app4:8080;
}

# In the server block:
location /app4 {
    proxy_pass http://app4_backend/;
}
```

Then regenerate the active config:
```bash
cp nginx/nginx-path.conf nginx/nginx.conf
```

#### Step 16: Deploy the New App
```bash
docker-compose up -d --build
```

## Exercises

### Exercise 1: Environment Variables
Add environment variables to app2:

**In docker-compose.yml:**
```yaml
  app2:
    environment:
      - APP_NAME=My Python App
      - DEBUG=false
```

**In app2-python/app.py:**
```python
import os
app_name = os.getenv('APP_NAME', 'Default Name')
```

### Exercise 2: Persistent Data
Add a volume to store data:

```yaml
  app2:
    volumes:
      - app2-data:/app/data

volumes:
  app2-data:
```

### Exercise 3: Health Checks
Add health checks to docker-compose.yml:

```yaml
  app1:
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Exercise 4: Custom Domain Names
Edit `/etc/hosts` (requires sudo):
```
127.0.0.1  myapp1.local
127.0.0.1  myapp2.local
```

Update nginx.conf to use server_name directives.

### Exercise 5: SSL/HTTPS
Generate self-signed certificates:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/nginx.key \
  -out nginx/certs/nginx.crt
```

Update nginx configuration for HTTPS.

## Common Issues

### Issue 1: Port Already in Use
**Error:** `bind: address already in use`

**Solution:**
```bash
# Find what's using port 80
lsof -i :80

# Kill the process or change docker-compose.yml
ports:
  - "8080:80"  # Use port 8080 instead
```

### Issue 2: Container Won't Start
**Solution:**
```bash
# Check logs
docker-compose logs [service-name]

# Remove and rebuild
docker-compose down
docker-compose up -d --build
```

### Issue 3: Can't Connect to App
**Solution:**
```bash
# Check if container is running
docker-compose ps

# Check if port is exposed
docker-compose port app1 3000

# Test from inside nginx container
docker exec -it nginx-proxy sh
wget -O- http://app1:3000
```

### Issue 4: Changes Not Reflected
**Solution:**
```bash
# Rebuild the specific service
docker-compose up -d --build [service-name]

# Or rebuild everything
docker-compose down
docker-compose up -d --build
```

## Next Steps

### Level 1: Beginner
- ✅ Get all three apps running
- ✅ Understand the nginx configuration
- ✅ Make a simple change to one app
- ✅ View logs to troubleshoot issues

### Level 2: Intermediate
- 🎯 Add a fourth application
- 🎯 Configure custom domain names
- 🎯 Add environment variables
- 🎯 Implement health checks
- 🎯 Set up persistent volumes

### Level 3: Advanced
- 🚀 Configure SSL/HTTPS
- 🚀 Set up load balancing
- 🚀 Implement logging aggregation
- 🚀 Add monitoring (Prometheus/Grafana)
- 🚀 Configure auto-scaling
- 🚀 Deploy to cloud (AWS/GCP/Azure)

### Recommended Reading
- Docker Documentation: https://docs.docker.com
- Nginx Documentation: https://nginx.org/en/docs/
- Docker Compose Reference: https://docs.docker.com/compose/
- Best Practices: https://docs.docker.com/develop/dev-best-practices/

### Real-World Scenarios
1. **Multiple Environments**: Create dev, staging, prod compose files
2. **CI/CD**: Integrate with GitHub Actions or GitLab CI
3. **Database Integration**: Add PostgreSQL or MongoDB
4. **Caching**: Add Redis for session storage
5. **API Gateway**: Expand nginx as a full API gateway

## Debugging Tips

### View Container Internals
```bash
# Enter container shell
docker exec -it app1-node sh

# View container processes
docker top app1-node

# Inspect container details
docker inspect app1-node
```

### Network Debugging
```bash
# Test connectivity between containers
docker exec app1-node ping app2

# Check DNS resolution
docker exec app1-node nslookup app2
```

### Resource Monitoring
```bash
# View resource usage
docker stats

# View container logs with timestamps
docker-compose logs -t app1
```

## Conclusion

You now have a complete learning environment for web hosting with Docker and Nginx! 

**Remember:**
- Start simple, then add complexity
- Read the logs when things break
- Experiment and break things (that's how you learn!)
- Document your changes

Happy learning! 🚀

