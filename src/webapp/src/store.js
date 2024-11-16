import { configureStore } from '@reduxjs/toolkit';
import { apiSlice, apiSliceReducer } from './slices/apiSlice';
import { cartSliceReducer } from './slices/cartSlice';
import { authSliceReducer } from './slices/authSlice';

const store = configureStore({
  reducer: {
    api: apiSliceReducer,
    cart: cartSliceReducer,
    auth: authSliceReducer,
  },
  middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(apiSlice.middleware),
  devTools: process.env.NODE_ENV !== 'production',
});

export default store;
