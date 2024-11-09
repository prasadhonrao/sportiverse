import { createSlice } from '@reduxjs/toolkit';

export const cartSlice = createSlice({
  name: 'cart',
  initialState: localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : { cartItems: [] },
  reducers: {},
});

export const cartSliceReducer = cartSlice.reducer;
