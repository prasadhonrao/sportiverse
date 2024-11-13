import express from 'express';
import { protect, admin } from '../middlewares/authMiddleware.js';
import { getProducts, getProductById, createProduct } from '../controllers/productController.js';

const router = express.Router();
router.route('/').get(getProducts).post(protect, admin, createProduct);
router.route('/:id').get(getProductById);

export default router;
