const express = require('express');
const app = express();
const PORT = 3000;

// Middleware to log requests
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Root endpoint
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>App 1 - Node.js</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    max-width: 800px;
                    margin: 50px auto;
                    padding: 20px;
                    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
                    color: white;
                }
                h1 { border-bottom: 3px solid white; padding-bottom: 10px; }
                .info {
                    background: rgba(255,255,255,0.1);
                    padding: 20px;
                    border-radius: 10px;
                    margin: 20px 0;
                    backdrop-filter: blur(10px);
                }
                .endpoint {
                    background: rgba(255,255,255,0.2);
                    padding: 15px;
                    margin: 10px 0;
                    border-radius: 5px;
                    font-family: monospace;
                }
                a { color: #ffeb3b; text-decoration: none; font-weight: bold; }
                a:hover { text-decoration: underline; }
                .back { margin-top: 30px; text-align: center; }
            </style>
        </head>
        <body>
            <h1>📦 App 1 - Node.js + Express</h1>
            <div class="info">
                <p><strong>Technology:</strong> Node.js v18 with Express framework</p>
                <p><strong>Container:</strong> Running on Alpine Linux</p>
                <p><strong>Internal Port:</strong> 3000</p>
                <p><strong>Purpose:</strong> Demonstrates a backend API service</p>
            </div>
            
            <h2>Available Endpoints:</h2>
            <div class="endpoint">
                <strong>GET /</strong> - This page
            </div>
            <div class="endpoint">
                <strong>GET /api/hello</strong> - <a href="/app1/api/hello">JSON response</a>
            </div>
            <div class="endpoint">
                <strong>GET /api/time</strong> - <a href="/app1/api/time">Current server time</a>
            </div>
            <div class="endpoint">
                <strong>GET /api/info</strong> - <a href="/app1/api/info">Server information</a>
            </div>
            
            <div class="back">
                <a href="/">← Back to Home</a>
            </div>
        </body>
        </html>
    `);
});

// API endpoints
app.get('/api/hello', (req, res) => {
    res.json({
        message: 'Hello from Node.js App 1!',
        timestamp: new Date().toISOString(),
        app: 'app1-node'
    });
});

app.get('/api/time', (req, res) => {
    res.json({
        serverTime: new Date().toISOString(),
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    });
});

app.get('/api/info', (req, res) => {
    res.json({
        app: 'App 1 - Node.js',
        version: process.version,
        platform: process.platform,
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

app.listen(PORT, () => {
    console.log(`App 1 (Node.js) listening on port ${PORT}`);
});

