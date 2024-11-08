import asyncHandler from '../middlewares/asyncHandler.js';
import Product from '../models/productModel.js';

// desc   Get all products
// route  GET /api/products
// access Public
const getProducts = asyncHandler(async (req, res) => {
  const products = await Product.find();
  res.status(200).json(products);
});

// desc   Get product by id
// route  GET /api/products/:id
// access Public
const getProductById = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);
  if (product) {
    return res.status(200).send(product);
  } else {
    return res.status(404).json({ message: 'Product not found' });
  }
});

export { getProducts, getProductById };
