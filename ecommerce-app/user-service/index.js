const express = require('express');
const { pool, connectWithRetry } = require('./db');

const app = express();
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'user-service' }));

app.get('/users', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, email, created_at FROM users ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.get('/users/:id', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, email, created_at FROM users WHERE id = $1', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.post('/users', async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: 'name and email are required' });
  try {
    const { rows } = await pool.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at',
      [name, email]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

const PORT = 3000;

connectWithRetry().then(() => {
  app.listen(PORT, () => console.log(`[user-service] listening on port ${PORT}`));
});

