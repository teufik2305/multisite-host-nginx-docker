from flask import Flask, jsonify, render_template_string
from datetime import datetime
import platform
import os

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>App 2 - Python Flask</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
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
        a { color: #fff59d; text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; }
        .back { margin-top: 30px; text-align: center; }
        .demo {
            background: rgba(255,255,255,0.15);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .counter {
            font-size: 2em;
            text-align: center;
            margin: 20px 0;
        }
    </style>
    <script>
        let count = 0;
        function updateCounter() {
            // Use relative path to work with both routing modes
            const apiPath = (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') 
                ? '/app2/api/counter' 
                : '/api/counter';
            
            fetch(apiPath)
                .then(response => response.json())
                .then(data => {
                    document.getElementById('counter').textContent = data.count;
                })
                .catch(error => console.error('Counter update failed:', error));
        }
        setInterval(updateCounter, 1000);
    </script>
</head>
<body>
    <h1>🐍 App 2 - Python Flask</h1>
    <div class="info">
        <p><strong>Technology:</strong> Python {{ python_version }} with Flask framework</p>
        <p><strong>Container:</strong> Running on Debian Slim</p>
        <p><strong>Internal Port:</strong> 5000</p>
        <p><strong>Purpose:</strong> Demonstrates a Python web application</p>
    </div>
    
    <div class="demo">
        <h3>Live Counter Demo</h3>
        <div class="counter" id="counter">{{ counter }}</div>
        <p style="text-align: center; font-size: 0.9em;">Updates every second</p>
    </div>
    
    <h2>Available Endpoints:</h2>
    <div class="endpoint">
        <strong>GET /</strong> - This page
    </div>
    <div class="endpoint">
        <strong>GET /api/status</strong> - <a href="api/status">JSON status</a>
    </div>
    <div class="endpoint">
        <strong>GET /api/counter</strong> - <a href="api/counter">Request counter</a>
    </div>
    <div class="endpoint">
        <strong>GET /api/system</strong> - <a href="api/system">System info</a>
    </div>
    
    <div class="back">
        <a href="#" onclick="goHome(); return false;">← Back to Home</a>
    </div>
    <script>
        function goHome() {
            // In DNS mode, go to localhost; in path mode, go to /
            if (window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
                window.location.href = 'http://localhost/';
            } else {
                window.location.href = '/';
            }
        }
    </script>
</body>
</html>
"""

# Simple counter to demonstrate state
request_counter = {'count': 0}

@app.before_request
def before_request():
    request_counter['count'] += 1
    print(f"[{datetime.now().isoformat()}] Request #{request_counter['count']}")

@app.route('/')
def home():
    return render_template_string(
        HTML_TEMPLATE,
        python_version=platform.python_version(),
        counter=request_counter['count']
    )

@app.route('/api/status')
def status():
    return jsonify({
        'status': 'healthy',
        'app': 'app2-python',
        'message': 'Hello from Python Flask!',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/counter')
def counter():
    return jsonify({
        'count': request_counter['count'],
        'message': f"This app has received {request_counter['count']} requests"
    })

@app.route('/api/system')
def system_info():
    return jsonify({
        'app': 'App 2 - Python Flask',
        'python_version': platform.python_version(),
        'platform': platform.platform(),
        'processor': platform.processor(),
        'hostname': os.environ.get('HOSTNAME', 'unknown')
    })

if __name__ == '__main__':
    print("Starting Flask app on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=False)

