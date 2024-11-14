import path from 'path';
import express from 'express';
import dotenv from 'dotenv';
import colors from 'colors';
import cookieParser from 'cookie-parser';

import connectDB from './config/db.js';

// Routes
import homeRoutes from './routes/homeRoutes.js';
import productRoutes from './routes/productRoutes.js';
import userRoutes from './routes/userRoutes.js';
import orderRoutes from './routes/orderRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';

// Middlewares
import { errorHandler } from './middlewares/errorHandler.js';

dotenv.config();

const port = process.env.PORT || 5000;
const env = process.env.NODE_ENV;

const app = express();

app.use(express.json()); // Body parser is used to parse JSON bodies
app.use(express.urlencoded({ extended: true })); // URL parser is used to parse URL-encoded bodies
app.use(cookieParser()); // Cookie parser is used to parse cookies

// Connect to MongoDB
connectDB();

// Custom routes
app.use('/', homeRoutes);
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/upload', uploadRoutes);

// PayPal routes
app.get('/api/config/paypal', (req, res) => res.send({ clientId: process.env.PAYPAL_CLIENT_ID }));

// Make uploads folder static
const __dirname = path.resolve();
app.use('/uploads', express.static(path.join(__dirname, '/uploads')));

// Custom middlewares
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Server running in ${env} mode on port ${port}`.yellow.bold);
});
