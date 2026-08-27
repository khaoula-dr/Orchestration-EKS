const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongo-db:27017/products';

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
});

const Product = mongoose.model('Product', productSchema);

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'product-service' }));

app.get('/products', async (req, res) => {
  try {
    const products = await Product.find().sort({ _id: 1 });
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.get('/products/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json(product);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.post('/products', async (req, res) => {
  const { name, price, stock } = req.body;
  if (!name || price === undefined) return res.status(400).json({ error: 'name and price are required' });
  try {
    const product = await Product.create({ name, price, stock });
    res.status(201).json(product);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  }
});

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

const PORT = 3000;

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
