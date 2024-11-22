import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { BASE_URL } from '../constants';

console.log(`Env: ${process.env.NODE_ENV}`);
console.log(`Base URL: ${BASE_URL}`);

export const apiSlice = createApi({
  baseQuery: fetchBaseQuery({ baseUrl: BASE_URL }),
  tagTypes: ['Product', 'User', 'Order'],
  // eslint-disable-next-line no-unused-vars
  endpoints: (builder) => ({}),
});

export const apiSliceReducer = apiSlice.reducer;
