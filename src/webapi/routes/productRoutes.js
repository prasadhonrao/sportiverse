import express from 'express';
import { protect, admin } from '../middlewares/authMiddleware.js';
import { getProducts, getProductById, createProduct, updateProduct } from '../controllers/productController.js';

const router = express.Router();
router.route('/').get(getProducts).post(protect, admin, createProduct);
router.route('/:id').get(getProductById).put(protect, admin, updateProduct);

export default router;
