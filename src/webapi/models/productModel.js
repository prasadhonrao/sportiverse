import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, 'Please provide a user id'],
      ref: 'User',
    },
    name: {
      type: String,
      minlength: [3, 'Product name must be between 3 and 100 characters'],
      maxlength: [100, 'Product name must be between 3 and 100 characters'],
      trim: true,
      unique: true,
    },
    description: {
      type: String,
      minlength: [10, 'Product description must be between 10 and 1000 characters'],
      maxlength: [1000, 'Product description must be between 10 and 1000 characters'],
      trim: true,
    },
    image: {
      type: String,
      description: String,
    },
    brand: {
      type: String,
      required: [true, 'Please provide a product brand'],
      minlength: [3, 'Product brand must be between 3 and 50 characters'],
      maxlength: [50, 'Product brand must be between 3 and 50 characters'],
      trim: true,
    },
    category: {
      type: String,
      required: [true, 'Please provide a product category'],
      minlength: [3, 'Product brand must be between 3 and 50 characters'],
      maxlength: [50, 'Product brand must be between 3 and 50 characters'],
      trim: true,
    },
    price: {
      type: Number,
      default: 0,
      required: [true, 'Please provide a product price'],
      min: [0, 'Product price must be greater than or equal to 0'],
    },
    countInStock: {
      type: Number,
      required: [true, 'Please provide a count in stock'],
      default: 0,
      min: [0, 'Count in stock must be greater than or equal to 0'],
    },
    reviews: [
      {
        name: {
          type: String,
          required: [true, 'Please provide a review name'],
          minlength: [3, 'Review name must be between 3 and 100 characters'],
          maxlength: [100, 'Review name must be between 3 and 100 characters'],
          trim: true,
        },
        rating: {
          type: Number,
          required: [true, 'Please provide a review rating'],
          min: [0, 'Review rating must be between 0 and 5'],
          max: [5, 'Review rating must be between 0 and 5'],
        },
        comment: {
          type: String,
          minlength: [3, 'Review comment must be between 3 and 10000 characters'],
          maxlength: [10000, 'Review comment must be between 3 and 10000 characters'],
        },
        user: {
          type: mongoose.Schema.Types.ObjectId,
          required: [true, 'User id is required to add a review'],
          ref: 'User',
        },
      },
      { timestamps: true },
    ],
    rating: {
      type: Number,
      required: true,
      default: 0,
      min: 0,
      max: 5,
    },
  },
  {
    timestamps: true,
    toObject: { virtuals: true },
    toJSON: { virtuals: true },
  }
);

productSchema.virtual('averageRating').get(function () {
  if (!this.ratings?.length) return 0;
  const sum = this.ratings?.reduce((acc, rating) => acc + rating.rating, 0) || 0;
  return sum / this.ratings?.length || 0;
});

productSchema.virtual('totalReviews').get(function () {
  return this.reviews?.length || 0;
});

productSchema.virtual('totalRatings').get(function () {
  return this.ratings?.length || 0;
});

const Product = mongoose.model('Product', productSchema);

export default Product;
