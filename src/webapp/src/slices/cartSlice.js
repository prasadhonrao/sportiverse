import { createSlice } from '@reduxjs/toolkit';
import { addDecimals } from '../utils/numberUtils';

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

      // Calculate items price
      state.itemsPrice = addDecimals(state.cartItems.reduce((acc, item) => acc + item.price * item.quantity, 0));

      // Calculate shipping price (free shipping if items price > 100 otherwise 10)
      state.shippingPrice = addDecimals(state.itemsPrice > 100 ? 0 : 10);

      // Calculate tax price (15% of items price)
      state.taxPrice = addDecimals(Number((0.15 * state.itemsPrice).toFixed(2)));

      // Calculate total price
      state.totalPrice = (Number(state.itemsPrice) + Number(state.shippingPrice) + Number(state.taxPrice)).toFixed(2);

      localStorage.setItem('cart', JSON.stringify(state));
    },
  },
});

export const { addToCart } = cartSlice.actions;
export const cartSliceReducer = cartSlice.reducer;
