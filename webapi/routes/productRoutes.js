import express from 'express';
import asyncHandler from '../middlewares/asyncHandler.js';
import Product from '../models/productModel.js';

const router = express.Router();

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const products = await Product.find({});
    res.status(200).json(products);
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    console.log(req.params.id);
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).send({ message: 'Product not found' });
    }

    return res.status(200).send(product);
  })
);

export default router;
