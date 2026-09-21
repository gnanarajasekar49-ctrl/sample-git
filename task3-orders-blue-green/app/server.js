const http = require('http');

const PORT = parseInt(process.env.PORT, 10) || 8081;
const APP_VERSION = process.env.APP_VERSION || '7.8.0';
const COLOR_SLOT = process.env.COLOR_SLOT || 'BLUE';
const GIT_COMMIT = process.env.GIT_COMMIT || 'unknown';
const DB_HOST = process.env.DB_HOST || 'orders-db';
const DB_PORT = parseInt(process.env.DB_PORT, 10) || 5432;
const SIMULATE_FAIL = process.env.SIMULATE_FAIL === 'true';

let orders = [
  { id: 101, customer: 'Enterprise Corp', item: 'Cloud Subscription', amount: 1200, status: 'Completed' },
  { id: 102, customer: 'Global Logistics', item: 'Server Rack Hosting', amount: 3400, status: 'Pending' }
];

function checkDb() {
  if (SIMULATE_FAIL || DB_HOST.includes('wrong') || !process.env.DB_PASSWORD) {
    return { ok: false, error: `Unable to establish connection to database at ${DB_HOST}:${DB_PORT}` };
  }
  return { ok: true, host: DB_HOST, port: DB_PORT, status: 'CONNECTED' };
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;

  res.setHeader('Content-Type', 'application/json');
  res.setHeader('X-Served-By-Slot', COLOR_SLOT);
  res.setHeader('X-App-Version', APP_VERSION);

  // Health Endpoint
  if (pathname === '/health') {
    const dbStatus = checkDb();
    if (!dbStatus.ok || SIMULATE_FAIL) {
      res.writeHead(500);
      return res.end(JSON.stringify({
        status: 'UNHEALTHY',
        slot: COLOR_SLOT,
        version: APP_VERSION,
        database: dbStatus,
        error: 'Critical dependency check failed'
      }));
    }
    res.writeHead(200);
    return res.end(JSON.stringify({
      status: 'HEALTHY',
      slot: COLOR_SLOT,
      version: APP_VERSION,
      uptime: Math.floor(process.uptime()),
      database: dbStatus,
      timestamp: new Date().toISOString()
    }));
  }

  // Version / Traceability Endpoint (Phase 4 requirement)
  if (pathname === '/version' || pathname === '/info') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      service: 'orders-api',
      slot: COLOR_SLOT,
      version: APP_VERSION,
      git_commit: GIT_COMMIT,
      port: PORT,
      database: DB_HOST
    }));
  }

  // Orders Endpoint
  if (pathname === '/api/orders') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      slot: COLOR_SLOT,
      version: APP_VERSION,
      count: orders.length,
      orders
    }));
  }

  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Endpoint not found', slot: COLOR_SLOT }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[Orders-API] Running on slot ${COLOR_SLOT} on port ${PORT}`);
  console.log(`[Orders-API] Version: ${APP_VERSION} | Git Commit: ${GIT_COMMIT}`);
});

process.on('SIGTERM', () => {
  console.log(`[Orders-API] Gracefully shutting down slot ${COLOR_SLOT}...`);
  server.close(() => process.exit(0));
});

