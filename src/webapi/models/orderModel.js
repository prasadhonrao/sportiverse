import mongoose from 'mongoose';

const orderSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, 'Please provide a user id'],
      ref: 'User',
    },
    orderItems: [
      {
        name: {
          type: String,
          required: [true, 'Please provide name'],
        },
        quantity: {
          type: Number,
          required: [true, 'Please provide quantity'],
        },
        image: {
          type: String,
          required: [true, 'Please provide image'],
        },
        price: {
          type: Number,
          required: [true, 'Please provide price'],
        },
        product: {
          type: mongoose.Schema.Types.ObjectId,
          required: [true, 'Please provide product id'],
          ref: 'Product',
        },
      },
    ],
    shippingAddress: {
      address: {
        type: String,
        required: [true, 'Please provide a shipping address'],
      },
      city: {
        type: String,
        required: [true, 'Please provide a city'],
      },
      postalCode: {
        type: String,
        required: [true, 'Please provide a postal code'],
      },
      country: {
        type: String,
        required: [true, 'Please provide a country'],
      },
    },
    paymentMethod: {
      type: String,
      required: [true, 'Please provide a payment method'],
    },
    paymentResult: {
      id: { type: String },
      status: { type: String },
      updateTime: { type: String },
      emailAddress: { type: String },
    },
    itemsPrice: {
      type: Number,
      required: [true, 'Please provide items price'],
      default: 0.0,
    },
    taxPrice: {
      type: Number,
      required: [true, 'Please provide tax price'],
      default: 0.0,
    },
    shippingPrice: {
      type: Number,
      required: [true, 'Please provide shipping price'],
      default: 0.0,
    },
    totalPrice: {
      type: Number,
      required: [true, 'Please provide total price'],
      default: 0.0,
    },
    isPaid: {
      type: Boolean,
      required: [true, 'Please provide payment status'],
      default: false,
    },
    paidAt: {
      type: Date,
    },
    isDelivered: {
      type: Boolean,
      required: [true, 'Please provide delivery status'],
      default: false,
    },
    deliveredAt: {
      type: Date,
    },
  },
  { timestamps: true }
);

const Order = mongoose.model('Order', orderSchema);

export default Order;
