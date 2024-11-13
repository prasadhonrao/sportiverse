import asyncHandler from '../middlewares/asyncHandler.js';
import Order from '../models/orderModel.js';

// desc   Create new order
// route  POST /api/orders
// access Private
const addOrderItems = asyncHandler(async (req, res) => {
  const { orderItems, shippingAddress, paymentMethod, itemsPrice, taxPrice, shippingPrice, totalPrice } = req.body;

  if (orderItems && orderItems.length === 0) {
    res.status(400);
    throw new Error('No order items');
  } else {
    const order = new Order({
      orderItems: orderItems.map((x) => ({
        ...x,
        product: x._id,
        _id: undefined,
      })),
      user: req.user._id,
      shippingAddress,
      paymentMethod,
      itemsPrice,
      taxPrice,
      shippingPrice,
      totalPrice,
    });
    const createdOrder = await order.save();
    res.status(201).json(createdOrder);
  }
});

// desc   Get logged in users order
// route  GET /api/orders/mine
// access Private
const getMyOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find({ user: req.user._id });
  res.status(200).json(orders);
});

// desc   Get order by Id
// route  GET /api/orders/:id
// access Private
const getOrderById = asyncHandler(async (req, res) => {
  const order = await Order.findById(req.params.id).populate('user', 'name email'); // populate user with name and email;
  if (order) {
    res.status(200).json(order);
  } else {
    res.status(404);
    throw new Error('Order not found');
  }
});

// desc   Update order to paid
// route  PUT /api/orders/:id/pay
// access Private
const updateOrderToPaid = asyncHandler(async (req, res) => {
  const order = await Order.findById(req.params.id);

  if (order) {
    order.isPaid = true;
    order.paidAt = Date.now();
    order.paymentResult = {
      id: req.body.id,
      status: req.body.status,
      updateTime: req.body.updateTime,
      emailAddress: req.body.emailAddress,
    };
    const updatedOrder = await order.save();
    return res.status(200).json(updatedOrder);
  } else {
    res.status(404);
    throw new Error('Order not found');
  }
});

// desc   Update order to delivered
// route  PUT /api/orders/:id/pay
// access Private/Admin
const updateOrderToDelivered = asyncHandler(async (req, res) => {
  const order = await Order.findById(req.params.id);

  if (order) {
    order.isDelivered = true;
    order.deliveredAt = Date.now();
    const updatedOrder = await order.save();
    return res.status(200).json(updatedOrder);
  } else {
    res.status(404);
    throw new Error('Order not found');
  }
});

// desc   Get all orders
// route  GET /api/orders
// access Private/Admin
const getOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find({}).populate('user', 'id name');
  res.status(200).json(orders);
});

export { addOrderItems, getMyOrders, getOrderById, updateOrderToPaid, updateOrderToDelivered, getOrders };
