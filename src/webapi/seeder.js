import dotenv from 'dotenv';
import colors from 'colors';

import users from './data/users.js';
import products from './data/products.js';
import orders from './data/orders.js';

import User from './models/userModel.js';
import Product from './models/productModel.js';
import Order from './models/orderModel.js';

import connectDB from './config/db.js';

dotenv.config();
connectDB();

const importData = async () => {
  try {
    // Delete existing data
    await Order.deleteMany();
    await Product.deleteMany();
    await User.deleteMany();

    // Insert data
    await User.insertMany(users);
    await Product.insertMany(products);
    await Order.insertMany(orders);

    console.log('Data Imported!'.yellow.bold);
    process.exit();
  } catch (error) {
    console.error(`Error occurred while importing data: ${error.stack}`.red.bold);
    process.exit(1);
  }
};

const destroyData = async () => {
  try {
    await Order.deleteMany();
    await Product.deleteMany();
    await User.deleteMany();
    console.log('Sample data deleted!'.yellow.bold);
    process.exit();
  } catch (error) {
    console.log(`Error occurred while deleting data: ${error.message}`.red.bold);
    process.exit(1);
  }
};

if (process.argv[2] === '-d') {
  destroyData();
} else {
  importData();
}
