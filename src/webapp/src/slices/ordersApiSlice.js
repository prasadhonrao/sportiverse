import { ORDERS_URL } from '../constants';
import { apiSlice } from './apiSlice';

export const ordersApiSlice = apiSlice.injectEndpoints({
  endpoints: (builder) => ({
    createOrder: builder.mutation({
      query: (order) => ({
        url: ORDERS_URL,
        method: 'POST',
        body: { ...order },
      }),
      providesTags: ['Order'],
      keepUnusedDataFor: 5,
    }),
  }),
});

export const { useCreateOrderMutation } = ordersApiSlice;
