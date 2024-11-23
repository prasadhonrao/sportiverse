import { createSlice } from '@reduxjs/toolkit';
import { updateCart } from '../utils/cartUtils';

const initialState = localStorage.getItem('cart')
  ? JSON.parse(localStorage.getItem('cart'))
  : { cartItems: [], shippingAddress: {}, paymentMethod: 'PayPal' };

export const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addToCart: (state, action) => {
      const item = action.payload;
      const itemExists = state.cartItems.find((x) => x._id === item._id);
      if (itemExists) {
        state.cartItems = state.cartItems.map((x) => (x._id === itemExists._id ? item : x));
      } else {
        state.cartItems = [...state.cartItems, item];
      }
      return updateCart(state);
    },
    removeFromCart: (state, action) => {
      state.cartItems = state.cartItems.filter((x) => x._id !== action.payload);
      return updateCart(state);
    },
    saveShippingAddress: (state, action) => {
      state.shippingAddress = action.payload;
      return updateCart(state);
    },
    savePaymentMethod: (state, action) => {
      state.paymentMethod = action.payload;
      return updateCart(state);
    },
    // eslint-disable-next-line no-unused-vars
    clearCartItems: (state, action) => {
      state.cartItems = [];
      return updateCart(state);
    },
    // eslint-disable-next-line no-unused-vars
    resetCart: (state) => (state = initialState),
  },
});

export const { addToCart, removeFromCart, saveShippingAddress, savePaymentMethod, clearCartItems, resetCart } =
  cartSlice.actions;
export const cartSliceReducer = cartSlice.reducer;
