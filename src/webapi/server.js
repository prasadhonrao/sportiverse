import path from 'path';
import express from 'express';
import dotenv from 'dotenv';
import colors from 'colors';
import cookieParser from 'cookie-parser';
import cors from 'cors';

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

// CORS configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : [];

// log the allowed origins
console.log('Allowed origins: ', allowedOrigins);

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true, // Allow cookies to be sent
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Allow these methods
  allowedHeaders: ['Content-Type', 'Authorization'], // Allow these headers
};

app.use(cors(corsOptions)); // Enable CORS with dynamic origins

// Set dummy header to test response
app.use((req, res, next) => {
  res.setHeader('X-Server', 'Node.js');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  console.log('Response Headers:', res.getHeaders()); // Log headers
  next();
});

// Connect to MongoDB
connectDB();

// Custom routes
app.use('/', homeRoutes);
app.use('/api/home', homeRoutes);
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/upload', uploadRoutes);

// PayPal routes
app.get('/api/config/paypal', (req, res) => res.send({ clientId: process.env.PAYPAL_CLIENT_ID }));

// File upload routes
// if (process.env.NODE_ENV === 'production') {
//   const __dirname = path.resolve();
//   const uploadPath = process.env.UPLOAD_PATH || '/uploads';
//   app.use('/uploads', express.static(uploadPath));
//   app.use(express.static(path.join(__dirname, '../webapp/build')));
//   app.get('*', (req, res) => res.sendFile(path.resolve(__dirname, 'webapp', 'build', 'index.html')));
// } else {
//   const __dirname = path.resolve();
//   app.use('/uploads', express.static(path.join(__dirname, '/uploads')));
//   app.get('/', (req, res) => {
//     res.send('API is running....');
//   });
// }

// File upload routes
const uploadPath = process.env.UPLOAD_PATH || path.join(__dirname, '/uploads');
app.use('/uploads', express.static(uploadPath));

// Custom middlewares
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Server running in ${env} mode on port ${port}`.yellow.bold);
});
