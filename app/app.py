from flask import Flask, render_template_string
import os
import socket
from datetime import datetime

app = Flask(__name__)

# HTML template
template = """
<!DOCTYPE html>
<html>
<head>
    <title>Jenkins-K8s Demo App</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        .status { 
            background: #28a745; 
            padding: 10px; 
            border-radius: 5px; 
            margin: 20px 0;
        }
        .info { 
            background: rgba(255,255,255,0.2); 
            padding: 15px; 
            border-radius: 5px; 
            margin: 10px 0;
        }
        h1 { color: #fff; text-align: center; }
        .version { font-size: 0.9em; opacity: 0.8; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Jenkins CI/CD → Kubernetes Demo</h1>
        
        <div class="status">
            <strong>✅ Application Status: RUNNING</strong>
        </div>
        
        <div class="info">
            <strong>🖥️ Hostname:</strong> {{ hostname }}
        </div>
        
        <div class="info">
            <strong>🕐 Current Time:</strong> {{ current_time }}
        </div>
        
        <div class="info">
            <strong>🌍 Environment:</strong> {{ environment }}
        </div>
        
        <div class="info">
            <strong>📦 Version:</strong> <span class="version">{{ version }}</span>
        </div>
        
        <div class="info">
            <strong>🔧 Built with:</strong> Python Flask + Docker + Kubernetes
        </div>
        
        <p style="text-align: center; margin-top: 30px;">
            <em>This app was deployed via Jenkins CI/CD pipeline! 🎉</em>
        </p>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(template,
        hostname=socket.gethostname(),
        current_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        environment=os.getenv('ENVIRONMENT', 'local'),
        version=os.getenv('APP_VERSION', '1.0.0')
    )

@app.route('/health')
def health():
    return {'status': 'healthy', 'timestamp': datetime.now().isoformat()}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)