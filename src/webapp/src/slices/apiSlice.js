import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { BASE_URL } from '../constants';

export const apiSlice = createApi({
  baseQuery: fetchBaseQuery({ baseUrl: BASE_URL }),
  tagTypes: ['Product', 'User', 'Order'],
  endpoints: (builder) => ({}),
});

export const apiSliceReducer = apiSlice.reducer;
