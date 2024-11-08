import express from 'express';
import dotenv from 'dotenv';
import colors from 'colors';
import products from './data/products.js';
import connectDB from './config/db.js';
import homeRoutes from './routes/homeRoutes.js';
import productRoutes from './routes/productRoutes.js';

dotenv.config();

const port = process.env.port || 5000;
const env = process.env.node_env;

const app = express();

// Connect to MongoDB
connectDB();

// Custom routes
app.use('/', homeRoutes);
app.use('/api/products', productRoutes);

app.listen(port, () => {
  console.log(`Server running in ${env} mode on port ${port}`.yellow.bold);
});
