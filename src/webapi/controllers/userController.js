import jwt from 'jsonwebtoken';
import asyncHandler from '../middlewares/asyncHandler.js';
import User from '../models/userModel.js';

// @desc    Authenticate user and return JWT token
// @route   POST /api/users/login
// @access  Public
const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });

  if (user && (await user.matchPassword(password))) {
    // Create JWT Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: '30d',
    });

    // Set JWT as HTTP-only cookie
    res.cookie('jwt', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
    });

    return res.status(200).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      isAdmin: user.isAdmin,
    });
  } else {
    res.status(401);
    throw new Error('Invalid email or password');
  }
});

// @desc    Register a new user
// @route   POST /api/users/register
// @access  Public
const registerUser = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Register route' });
});

// @desc    Log user out / clear cookie
// @route   POST /api/users/logout
// @access  Private
const logoutUser = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Logout route' });
});

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Get user profile route' });
});

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Update user profile' });
});

// desc   Get all users
// route  GET /api/users
// access Private/Admin
const getUsers = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Get all users route' });
});

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Private / Admin
const getUserById = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Get user by ID route' });
});

// @desc    Update user
// @route   POST /api/users/:id
// @access  Private / Admin
const updateUser = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Update user route' });
});

// desc   Delete a user
// route  DELETE /api/users/:id
// access Private/Admin
const deleteUser = asyncHandler(async (req, res) => {
  res.status(200).json({ message: 'Delete user route' });
});

export {
  loginUser,
  logoutUser,
  registerUser,
  getUserProfile,
  updateUserProfile,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
};
