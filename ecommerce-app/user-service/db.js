const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'postgres-db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'usersdb',
  port: 5432,
});

const MAX_RETRIES = 10;
const RETRY_INTERVAL_MS = 3000;

async function connectWithRetry(retries = MAX_RETRIES) {
  try {
    await pool.query('SELECT 1');
    console.log('[user-service] Connected to Postgres (usersdb)');
    await initSchema();
  } catch (err) {
    if (retries === 0) {
      console.error('[user-service] Could not connect to Postgres after multiple retries:', err.message);
      process.exit(1);
    }
    console.log(`[user-service] Postgres not ready, retrying in ${RETRY_INTERVAL_MS / 1000}s... (${retries} attempts left)`);
    await new Promise((res) => setTimeout(res, RETRY_INTERVAL_MS));
    return connectWithRetry(retries - 1);
  }
}

async function initSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    );
  `);
  const { rows } = await pool.query('SELECT COUNT(*) FROM users');
  if (parseInt(rows[0].count, 10) === 0) {
    await pool.query(
      `INSERT INTO users (name, email) VALUES
       ('Alice Dupont', 'alice@example.com'),
       ('Bob Martin', 'bob@example.com')`
    );
    console.log('[user-service] Seed data inserted');
  }
}

module.exports = { pool, connectWithRetry };
