import { createSlice } from '@reduxjs/toolkit';
import { updateCart } from '../utils/cartUtils';

export const cartSlice = createSlice({
  name: 'cart',
  initialState: localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : { cartItems: [] },
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
  },
});

export const { addToCart } = cartSlice.actions;
export const cartSliceReducer = cartSlice.reducer;