import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a user name'],
      minlength: [2, 'Name must be between 2 and 50 characters'],
      maxlength: [50, 'Name must be between 2 and 50 characters'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Please provide a user email address'],
      unique: true,
      trim: true,
    },
    password: {
      type: String,
      required: [true, 'Please provide a user password'],
      minlength: [6, 'Password must be at least 6 characters'],
      trim: true,
    },
    isAdmin: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);

export default User;
