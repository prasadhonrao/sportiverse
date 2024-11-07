import express from 'express';
import dotenv from 'dotenv';
import products from './data/products.js';

dotenv.config();

const port = process.env.port || 5000;
const env = process.env.NODE_ENV;

const app = express();

app.get('/', (req, res) => {
  res.send('Sai Sports Web API is running');
});

app.get('/api/products', (req, res) => {
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find((p) => (p._id = req.params.id));
  res.send(product);
});

app.listen(port, () => {
  console.log(`Server running in ${env} mode on port ${port}`);
});
