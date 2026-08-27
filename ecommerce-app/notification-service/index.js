const express = require('express');

const app = express();
app.use(express.json());

// Stockage en mémoire (pas de DB, aucune persistance)
const notifications = [];

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'notification-service' }));

app.get('/notifications', (req, res) => {
  res.json(notifications);
});

app.post('/notifications', (req, res) => {
  const { userId, message, type } = req.body;
  if (!userId || !message) return res.status(400).json({ error: 'userId and message are required' });

  const notification = {
    id: notifications.length + 1,
    userId,
    message,
    type: type || 'info',
    createdAt: new Date().toISOString(),
  };
  notifications.push(notification);
  console.log(`[notification-service] New notification for user ${userId}: ${message}`);
  res.status(201).json(notification);
});

const PORT = 3000;
app.listen(PORT, () => console.log(`[notification-service] listening on port ${PORT}`));
