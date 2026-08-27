const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'postgres-db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'ordersdb',
  port: 5432,
});

const MAX_RETRIES = 10;
const RETRY_INTERVAL_MS = 3000;

async function connectWithRetry(retries = MAX_RETRIES) {
  try {
    await pool.query('SELECT 1');
    console.log('[order-service] Connected to Postgres (ordersdb)');
    await initSchema();
  } catch (err) {
    if (retries === 0) {
      console.error('[order-service] Could not connect to Postgres after multiple retries:', err.message);
      process.exit(1);
    }
    console.log(`[order-service] Postgres not ready, retrying in ${RETRY_INTERVAL_MS / 1000}s... (${retries} attempts left)`);
    await new Promise((res) => setTimeout(res, RETRY_INTERVAL_MS));
    return connectWithRetry(retries - 1);
  }
}

async function initSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS orders (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL,
      product_id VARCHAR(64) NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      status VARCHAR(50) DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT NOW()
    );
  `);
}

module.exports = { pool, connectWithRetry };
