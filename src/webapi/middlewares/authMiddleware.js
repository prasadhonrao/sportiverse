import jwt from 'jsonwebtoken';
import asyncHandler from './asyncHandler.js';
import User from '../models/userModel.js';

const protect = asyncHandler(async (req, res, next) => {
  // Read JWT from token
  let token = req.cookies.jwt;

  if (token) {
    try {
      // Verify JWT
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Find user based on the decoded JWT
      const user = await User.findById(decoded.userId).select('-password');

      if (!user) {
        res.status(404);
        throw new Error('User not found with this id');
      }

      // Attach user to request object
      req.user = user;

      next();
    } catch {
      res.status(401);
      throw new Error('Not authorized, token failed');
    }
  } else {
    res.status(401);
    throw new Error('Not authorized, no token');
  }
});

const admin = (req, res, next) => {
  if (req.user && req.user.isAdmin) {
    next();
  } else {
    res.status(401);
    throw new Error('Not authorized as admin');
  }
};

export { protect, admin };
