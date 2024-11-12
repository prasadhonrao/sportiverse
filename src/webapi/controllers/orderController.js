import asyncHandler from '../middlewares/asyncHandler.js';
import Order from '../models/orderModel.js';

// desc   Create new order
// route  POST /api/orders
// access Private
const addOrderItems = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Add order items' });
});

// desc   Get logged in users order
// route  GET /api/orders/mine
// access Private
const getMyOrders = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Get my orders' });
});

// desc   Get order by Id
// route  GET /api/orders/:id
// access Private
const getOrderById = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Get order by id' });
});

// desc   Update order to paid
// route  POST /api/orders/:id/pay
// access Private
const updateOrderToPaid = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Update order to paid' });
});

// desc   Update order to delivered
// route  POST /api/orders/:id/pay
// access Private/Admin
const updateOrderToDelivered = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Update order to delivered' });
});

// desc   Get all orders
// route  POST /api/orders
// access Private/Admin
const getOrders = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'get orders' });
});

export { addOrderItems, getMyOrders, getOrderById, updateOrderToPaid, updateOrderToDelivered, getOrders };
