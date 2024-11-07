import express from 'express';
import products from './data/products.js';

const port = process.env.port || 5000;
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
  console.log(`Sai Sports Web API is running on port ${port}`);
});
