const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const BACKEND_PORT = 5000;
const FILE_PATH = path.join(__dirname, 'index.html');

const server = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Forward API requests to the Python ML backend on port 5000 if requested through node server
  if (req.url.startsWith('/api/')) {
    const options = {
      hostname: '127.0.0.1',
      port: BACKEND_PORT,
      path: req.url,
      method: req.method,
      headers: req.headers
    };

    const proxy = http.request(options, (targetRes) => {
      res.writeHead(targetRes.statusCode, targetRes.headers);
      targetRes.pipe(res, { end: true });
    });

    proxy.on('error', (err) => {
      res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        error: 'ML Backend unreachable',
        message: 'Ensure Python ML backend is running with: python backend/app.py',
        details: err.message
      }));
    });

    req.pipe(proxy, { end: true });
    return;
  }

  // Otherwise serve the web preview
  fs.readFile(FILE_PATH, (err, content) => {
    if (err) {
      res.writeHead(500);
      res.end('Error loading frontend preview: ' + err.message);
    } else {
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`Web preview server running at http://localhost:${PORT}`);
  console.log(`Forwarding /api/* requests to ML Backend at http://127.0.0.1:${BACKEND_PORT}`);
});
