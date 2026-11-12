'use strict';

// Static website server for the user's exact folder structure:
// outer folder contains this file and backend/
// inner ./brand-resource-hub/ folder contains index.html

const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const HOST = '127.0.0.1';
const PORT = 5500;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.txt': 'text/plain; charset=utf-8'
};

const server = http.createServer((req, res) => {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { Allow: 'GET, HEAD' });
    return res.end('Method Not Allowed');
  }

  let pathname;
  try {
    pathname = decodeURIComponent(new URL(req.url, `http://${HOST}:${PORT}`).pathname);
  } catch {
    res.writeHead(400);
    return res.end('Bad Request');
  }

  const requestedPath = path.resolve(ROOT, `.${pathname}`);
  if (requestedPath !== ROOT && !requestedPath.startsWith(ROOT + path.sep)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }

  let filePath = requestedPath;
  try {
    if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }
  } catch {
    res.writeHead(404);
    return res.end('Not Found');
  }

  fs.readFile(filePath, (error, contents) => {
    if (error) {
      res.writeHead(error.code === 'ENOENT' ? 404 : 500);
      return res.end(error.code === 'ENOENT' ? 'Not Found' : 'Server Error');
    }

    res.writeHead(200, {
      'Content-Type': MIME_TYPES[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-cache'
    });
    if (req.method === 'HEAD') return res.end();
    res.end(contents);
  });
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.log(`Port ${PORT} is already in use. An existing web server may already be running.`);
  } else {
    console.error('Website server error:', error.message);
  }
  process.exitCode = 1;
});

server.listen(PORT, HOST, () => {
  console.log(`Brand Resource Hub website: http://${HOST}:${PORT}/brand-resource-hub/index.html`);
  console.log('Keep this window open while using the website.');
});
