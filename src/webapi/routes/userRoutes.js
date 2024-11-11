import express from 'express';

import {
  loginUser,
  logoutUser,
  registerUser,
  getUserProfile,
  updateUserProfile,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
} from '../controllers/userController.js';

const router = express.Router();

router.route('/').get(getUsers).post(registerUser);
router.route('/profile').get(getUserProfile).put(updateUserProfile);
router.route('/login').post(loginUser);
router.route('/logout').post(logoutUser);
router.route('/:id').get(getUserById).put(updateUser).delete(deleteUser);

export default router;
