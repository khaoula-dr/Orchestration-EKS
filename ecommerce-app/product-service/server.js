const mongoose = require('mongoose');
const { app, Product } = require('./app');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongo-db:27017/products';
const PORT = 3000;

async function seedIfEmpty() {
  const count = await Product.countDocuments();
  if (count === 0) {
    await Product.insertMany([
      { name: 'T-shirt', price: 19.99, stock: 100 },
      { name: 'Casquette', price: 14.5, stock: 50 },
    ]);
    console.log('[product-service] Seed data inserted');
  }
}

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log('[product-service] Connected to MongoDB');
    await seedIfEmpty();
    app.listen(PORT, () => console.log(`[product-service] listening on port ${PORT}`));
  })
  .catch((err) => {
    console.error('[product-service] MongoDB connection error:', err.message);
    process.exit(1);
  });
