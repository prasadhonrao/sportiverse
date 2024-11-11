import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

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

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);

export default User;
