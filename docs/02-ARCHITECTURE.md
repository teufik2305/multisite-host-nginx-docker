# Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet / Browser                     │
│                       http://localhost:80                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP Requests
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Nginx Reverse Proxy                          │
│                    (Port 80 → Public)                           │
│                                                                 │
│  Routes based on URL path:                                      │
│  • /app1 → app1:3000                                            │
│  • /app2 → app2:5000                                            │
│  • /app3 → app3:80                                              │
└─────────────────────────────────────────────────────────────────┘
                   │              │              │
                   │              │              │
      ┌────────────┘              │              └────────────┐
      │                           │                           │
      ▼                           ▼                           ▼
┌──────────────┐        ┌──────────────┐         ┌──────────────┐
│   App 1      │        │   App 2      │         │   App 3      │
│   Node.js    │        │   Python     │         │   Static     │
│   Express    │        │   Flask      │         │   Nginx      │
│              │        │              │         │              │
│   Port 3000  │        │   Port 5000  │         │   Port 80    │
│   (Internal) │        │   (Internal) │         │   (Internal) │
└──────────────┘        └──────────────┘         └──────────────┘
```

## Docker Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Docker Network: webnet                    │
│                       (bridge driver)                           │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   nginx      │  │   app1       │  │   app2       │           │
│  │   Container  │  │   Container  │  │   Container  │           │
│  │              │  │              │  │              │           │
│  │  IP: auto    │  │  IP: auto    │  │  IP: auto    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                 │
│  ┌──────────────┐                                               │
│  │   app3       │                                               │
│  │   Container  │         All containers can communicate        │
│  │              │         using service names (DNS)             │
│  │  IP: auto    │                                               │
│  └──────────────┘                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Request Flow Example

### Accessing App 1 (Node.js)

```
1. User visits: http://localhost/app1

2. Request hits host machine's port 80

3. Docker forwards to nginx container port 80

4. Nginx reads request path: /app1

5. Nginx matches location block:
   location /app1 {
       proxy_pass http://app1_backend/;
   }

6. Nginx forwards request to app1:3000
   (Docker's internal DNS resolves "app1" to container IP)

7. Node.js app processes request

8. Response flows back through nginx to user
```

## Component Responsibilities

### Nginx Container
- **Primary Role**: Reverse proxy and load balancer
- **Port Mapping**: Host 80 → Container 80
- **Functions**:
  - Route incoming requests
  - Add proxy headers
  - Serve landing page
  - Enable gzip compression
  - Handle SSL/TLS (in production)
- **Config**: `/etc/nginx/nginx.conf`

### App1 Container (Node.js)
- **Technology**: Node.js 18 + Express
- **Port**: 3000 (internal only, not exposed to host)
- **Purpose**: Demonstrates backend API service
- **Endpoints**:
  - `GET /` - Web interface
  - `GET /api/hello` - JSON API
  - `GET /api/time` - Time service
  - `GET /api/info` - Server info

### App2 Container (Python)
- **Technology**: Python 3.11 + Flask
- **Port**: 5000 (internal only)
- **Purpose**: Demonstrates Python web application
- **Features**:
  - Dynamic HTML rendering
  - Request counter (demonstrates state)
  - Real-time updates via JavaScript

### App3 Container (Static)
- **Technology**: Nginx serving static files
- **Port**: 80 (internal only)
- **Purpose**: Demonstrates static site hosting
- **Contents**:
  - HTML/CSS/JavaScript
  - Client-side interactivity
  - No backend processing

## Network Security

```
┌─────────────────────────────────────────────────────────────────┐
│                         Host Machine                            │
│                                                                 │
│  Port 80 OPEN (accessible from outside)                         │
│      ↓                                                          │
│  Only nginx container exposed                                   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Internal Docker Network (isolated)                     │    │
│  │                                                         │    │
│  │  ✅ nginx → app1 (allowed via internal network)         │    │
│  │  ✅ nginx → app2 (allowed via internal network)         │    │
│  │  ✅ nginx → app3 (allowed via internal network)         │    │
│  │                                                         │    │
│  │  ❌ Direct access to app1:3000 (blocked from outside)   │    │
│  │  ❌ Direct access to app2:5000 (blocked from outside)   │    │
│  │  ❌ Direct access to app3:80   (blocked from outside)   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Security Benefits:**
- Backend services are not directly accessible from the internet
- Single entry point (nginx) makes security monitoring easier
- Can add authentication at nginx level for all apps
- SSL termination happens at one place

## Scaling Options

### Horizontal Scaling (Multiple Instances)

```yaml
# In docker-compose.yml
services:
  app1:
    build: ./app1-node
    deploy:
      replicas: 3  # Run 3 instances
```

Nginx configuration for load balancing:
```nginx
upstream app1_backend {
    server app1_1:3000;
    server app1_2:3000;
    server app1_3:3000;
}
```

### Vertical Scaling (Resource Limits)

```yaml
services:
  app1:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## Data Flow Patterns

### Stateless Applications (App 1 & 3)
```
Request → Nginx → App → Response
(No data persists between requests)
```

### Stateful Applications (App 2)
```
Request → Nginx → App → Check State → Update State → Response
(Counter persists in memory)
```

### With Persistent Storage
```
Request → Nginx → App → Database/Volume → Response
(Data survives container restarts)
```

## Development vs Production

### Development (Current Setup)
- All services on one machine
- Direct port mapping
- No SSL
- Minimal security
- Easy debugging

### Production Recommendations
```
┌──────────────────────────────────────────────┐
│  Load Balancer (AWS ALB, Cloudflare)         │
│  - SSL/TLS termination                       │
│  - DDoS protection                           │
└────────────────┬─────────────────────────────┘
                 │
┌────────────────▼─────────────────────────────┐
│  Nginx Reverse Proxy                         │
│  - Multiple instances for HA                 │
│  - Health checks                             │
│  - Rate limiting                             │
└────────────────┬─────────────────────────────┘
                 │
┌────────────────▼─────────────────────────────┐
│  Application Containers                      │
│  - Auto-scaling based on load                │
│  - Container orchestration (K8s/ECS)         │
│  - Monitoring and logging                    │
└────────────────┬─────────────────────────────┘
                 │
┌────────────────▼─────────────────────────────┐
│  Data Layer                                  │
│  - Managed databases (RDS, MongoDB Atlas)    │
│  - Object storage (S3)                       │
│  - Cache layer (Redis/Memcached)             │
└──────────────────────────────────────────────┘
```

## File Structure

```
multisite-host-nginx-docker/
│
├── docker-compose.yml          # Orchestration
│   └── Defines: services, networks, volumes
│
├── nginx/
│   └── nginx.conf              # Routing rules
│
├── app1-node/
│   ├── Dockerfile              # Image definition
│   ├── package.json            # Dependencies
│   └── server.js               # Application code
│
├── app2-python/
│   ├── Dockerfile
│   ├── requirements.txt        # Python packages
│   └── app.py
│
├── app3-static/
│   ├── Dockerfile
│   ├── nginx.conf              # Static server config
│   └── html/
│       ├── index.html
│       ├── style.css
│       └── script.js
│
└── Documentation
    ├── README.md               # Quick start
    ├── LEARNING_GUIDE.md       # Step-by-step tutorial
    └── ARCHITECTURE.md         # This file
```

## Common Operations

### Starting the Stack
```bash
docker-compose up -d
```

### Viewing Logs
```bash
docker-compose logs -f nginx    # Just nginx
docker-compose logs -f          # All services
```

### Restarting a Service
```bash
docker-compose restart app1
```

### Rebuilding After Changes
```bash
docker-compose up -d --build app1
```

### Stopping Everything
```bash
docker-compose down
```

### Complete Reset
```bash
docker-compose down -v          # Also removes volumes
docker-compose up -d --build    # Rebuild everything
```

## Next Steps

After understanding this architecture, you can:

1. **Add Authentication**: Implement JWT tokens or OAuth
2. **Add Database**: PostgreSQL, MongoDB, or MySQL
3. **Add Caching**: Redis for session storage
4. **Add Message Queue**: RabbitMQ or Kafka
5. **Add Monitoring**: Prometheus + Grafana
6. **Add Logging**: ELK stack (Elasticsearch, Logstash, Kibana)
7. **Deploy to Cloud**: AWS ECS, Google Cloud Run, or Kubernetes

This architecture scales from learning on your laptop to production environments serving millions of users!

