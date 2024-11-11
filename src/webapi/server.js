import express from 'express';
import dotenv from 'dotenv';
import colors from 'colors';

import connectDB from './config/db.js';

// Routes
import homeRoutes from './routes/homeRoutes.js';
import productRoutes from './routes/productRoutes.js';
import userRoutes from './routes/userRoutes.js';

// Middlewares
import { errorHandler } from './middlewares/errorHandler.js';

dotenv.config();

const port = process.env.PORT || 5000;
const env = process.env.NODE_ENV;

const app = express();

app.use(express.json()); // Body parser
app.use(express.urlencoded({ extended: true })); // URL parser

// Connect to MongoDB
connectDB();

// Custom routes
app.use('/', homeRoutes);
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);

// Custom middlewares
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Server running in ${env} mode on port ${port}`.yellow.bold);
});
