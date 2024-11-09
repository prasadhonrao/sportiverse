import { configureStore } from '@reduxjs/toolkit';
import { apiSlice, apiSliceReducer } from './slices/apiSlice';
import { cartSliceReducer } from './slices/cartSlice';

const store = configureStore({
  reducer: {
    api: apiSliceReducer,
    cart: cartSliceReducer,
  },
  middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(apiSlice.middleware),
  devTools: process.env.NODE_ENV !== 'production',
});

export default store;
