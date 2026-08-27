const express = require('express');
const { pool, connectWithRetry } = require('./db');
const { getUser, getProduct, notifyUser } = require('./circuitBreaker');

const app = express();
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'order-service' }));

app.get('/orders', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM orders ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.get('/orders/:id', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM orders WHERE id = $1', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Order not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

// Crée une commande : vérifie l'utilisateur et le produit, insère la commande,
// puis notifie l'utilisateur via notification-service.
app.post('/orders', async (req, res) => {
  const { userId, productId, quantity } = req.body;
  if (!userId || !productId) {
    return res.status(400).json({ error: 'userId and productId are required' });
  }

  try {
    // Vérifie que l'utilisateur existe (passe par le circuit breaker : timeout 3s,
    // et si user-service est en panne de façon répétée, échoue vite au lieu d'attendre)
    const user = await getUser(userId).catch(() => null);
    if (!user) {
      return res.status(400).json({ error: `User ${userId} not found or user-service unavailable` });
    }

    // Vérifie que le produit existe (même protection)
    const product = await getProduct(productId).catch(() => null);
    if (!product) {
      return res.status(400).json({ error: `Product ${productId} not found or product-service unavailable` });
    }

    // Insère la commande
    const { rows } = await pool.query(
      `INSERT INTO orders (user_id, product_id, quantity, status)
       VALUES ($1, $2, $3, 'confirmed') RETURNING *`,
      [userId, productId, quantity || 1]
    );
    const order = rows[0];

    // Notifie l'utilisateur (best-effort : le circuit breaker a déjà un fallback silencieux,
    // donc pas besoin d'un try/catch supplémentaire ici)
    await notifyUser({
      userId,
      message: `Votre commande #${order.id} pour "${product.name}" a été confirmée.`,
      type: 'order_confirmation',
    });

    res.status(201).json(order);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

const PORT = 3000;

connectWithRetry().then(() => {
  app.listen(PORT, () => console.log(`[order-service] listening on port ${PORT}`));
});
