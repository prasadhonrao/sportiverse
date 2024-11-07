import express from 'express';
import dotenv from 'dotenv';
import colors from 'colors';
import products from './data/products.js';
import connectDB from './config/db.js';

dotenv.config();

const port = process.env.port || 5000;
const env = process.env.node_env;

const app = express();

// Connect to MongoDB
connectDB();

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
  console.log(`Server running in ${env} mode on port ${port}`.yellow.bold);
});
