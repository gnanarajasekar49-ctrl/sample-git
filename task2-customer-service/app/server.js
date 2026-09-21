const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = parseInt(process.env.PORT, 10) || 8081;
const APP_VERSION = process.env.APP_VERSION || '5.0.0';
const ENVIRONMENT = process.env.ENVIRONMENT || process.env.NODE_ENV || 'DEV';
const DB_HOST = process.env.DB_HOST || 'customer-db-dev';
const DB_PORT = parseInt(process.env.DB_PORT, 10) || 5432;
const FAIL_DB_CONNECTION = process.env.FAIL_DB_CONNECTION === 'true' || APP_VERSION === '5.1.0-fail';

// Seed initial customers
let customers = [
  { id: 1, name: 'Alice Smith', email: 'alice@enterprise.com', tier: 'Enterprise', env: ENVIRONMENT },
  { id: 2, name: 'Bob Johnson', email: 'bob@techcorp.io', tier: 'Business', env: ENVIRONMENT },
  { id: 3, name: 'Charlie Brown', email: 'charlie@startup.co', tier: 'Standard', env: ENVIRONMENT }
];

// Helper to check DB connectivity
function checkDatabaseConnection() {
  if (FAIL_DB_CONNECTION || DB_HOST.includes('invalid') || DB_HOST.includes('wrong-host')) {
    return { connected: false, error: `Connection refused to database at ${DB_HOST}:${DB_PORT}` };
  }
  return { connected: true, host: DB_HOST, port: DB_PORT, status: 'READY' };
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;

  res.setHeader('Content-Type', 'application/json');

  // Deployment Validation Endpoint 22: Application Health Endpoint
  if (pathname === '/health') {
    const dbStatus = checkDatabaseConnection();
    if (!dbStatus.connected) {
      res.writeHead(500);
      return res.end(JSON.stringify({
        status: 'DOWN',
        version: APP_VERSION,
        environment: ENVIRONMENT,
        database: dbStatus,
        error: 'Database connection failed during healthcheck'
      }));
    }

    res.writeHead(200);
    return res.end(JSON.stringify({
      status: 'UP',
      version: APP_VERSION,
      environment: ENVIRONMENT,
      database: dbStatus,
      uptime: Math.floor(process.uptime()),
      timestamp: new Date().toISOString()
    }));
  }

  // Deployment Validation Endpoint 23: Application Can Reach Database
  if (pathname === '/api/db-status') {
    const dbStatus = checkDatabaseConnection();
    const statusCode = dbStatus.connected ? 200 : 503;
    res.writeHead(statusCode);
    return res.end(JSON.stringify({
      app: `customer-app-${ENVIRONMENT.toLowerCase()}`,
      version: APP_VERSION,
      environment: ENVIRONMENT,
      database_host: DB_HOST,
      database_connection: dbStatus
    }));
  }

  // Deployment Validation Endpoint 24 & 25: Expected Environment & Version
  if (pathname === '/version' || pathname === '/info') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      application: `customer-app-${ENVIRONMENT.toLowerCase()}`,
      version: APP_VERSION,
      environment: ENVIRONMENT,
      database_target: DB_HOST,
      port: PORT
    }));
  }

  // Feature: Customer Search Endpoint (Task 2 Git Strategy)
  if (pathname === '/api/search') {
    const query = (url.searchParams.get('q') || '').toLowerCase();
    const results = customers.filter(c => 
      c.name.toLowerCase().includes(query) || 
      c.email.toLowerCase().includes(query) || 
      c.tier.toLowerCase().includes(query)
    );
    res.writeHead(200);
    return res.end(JSON.stringify({
      query,
      count: results.length,
      environment: ENVIRONMENT,
      results
    }));
  }

  if (pathname === '/api/customers') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      total: customers.length,
      environment: ENVIRONMENT,
      customers
    }));
  }

  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Endpoint not found', path: pathname }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[Customer-Service] Running on port ${PORT}`);
  console.log(`[Customer-Service] Environment: ${ENVIRONMENT} | Version: ${APP_VERSION}`);
  console.log(`[Customer-Service] DB Target: ${DB_HOST}:${DB_PORT}`);
});

process.on('SIGTERM', () => {
  console.log('[Customer-Service] Shutting down cleanly...');
  server.close(() => process.exit(0));
});

