const http = require('http');

const PORT = parseInt(process.env.PORT, 10) || 8081;
const APP_VERSION = process.env.APP_VERSION || '4.2.0';
const GIT_COMMIT = process.env.GIT_COMMIT || 'unknown';
const ENVIRONMENT = process.env.NODE_ENV || 'production';
const SIMULATE_FAILURE = process.env.SIMULATE_FAILURE === 'true' || process.env.HEALTH_STATUS === 'FAIL';

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;

  res.setHeader('Content-Type', 'application/json');

  if (pathname === '/health') {
    if (SIMULATE_FAILURE || APP_VERSION === '4.2.2') {
      res.writeHead(500);
      return res.end(JSON.stringify({
        status: 'DOWN',
        version: APP_VERSION,
        error: 'Health check failed: simulated critical component error',
        timestamp: new Date().toISOString()
      }));
    }
    res.writeHead(200);
    return res.end(JSON.stringify({
      status: 'UP',
      version: APP_VERSION,
      uptime: Math.floor(process.uptime()),
      environment: ENVIRONMENT,
      timestamp: new Date().toISOString()
    }));
  }

  if (pathname === '/version') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      version: APP_VERSION,
      commit: GIT_COMMIT,
      environment: ENVIRONMENT
    }));
  }

  if (pathname === '/api/payment') {
    if (APP_VERSION === '4.2.0') {
      res.writeHead(500);
      return res.end(JSON.stringify({
        status: 'FAILED',
        version: APP_VERSION,
        error: 'Critical payment gateway exception: transaction aborted in v4.2.0 baseline'
      }));
    }
    res.writeHead(200);
    return res.end(JSON.stringify({
      status: 'SUCCESS',
      version: APP_VERSION,
      message: 'Payment gateway operational and transaction processed successfully',
      transactionId: 'TXN-' + Math.floor(Math.random() * 1000000)
    }));
  }

  if (pathname === '/' || pathname === '/api/products') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      name: 'Retail Platform Online Store',
      version: APP_VERSION,
      environment: ENVIRONMENT,
      products: [
        { id: 1, name: 'Cloud Native DevOps Handbook', price: 49.99 },
        { id: 2, name: 'Docker & Kubernetes Deep Dive', price: 59.99 },
        { id: 3, name: 'CI/CD Pipeline Mastery', price: 39.99 }
      ]
    }));
  }

  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Endpoint not found', path: pathname }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[Retail-Platform] Server running on port ${PORT} (Version: ${APP_VERSION}, Env: ${ENVIRONMENT})`);
});

process.on('SIGTERM', () => {
  console.log('[Retail-Platform] SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('[Retail-Platform] HTTP server closed');
    process.exit(0);
  });
});




