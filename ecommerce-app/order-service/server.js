const app = require('./app');
const { connectWithRetry } = require('./db');

const PORT = 3000;

connectWithRetry().then(() => {
  app.listen(PORT, () => console.log(`[order-service] listening on port ${PORT}`));
});
