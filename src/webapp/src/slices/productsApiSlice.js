import { PRODUCTS_URL } from '../constants';
import { apiSlice } from './apiSlice';

export const productsApiSlice = apiSlice.injectEndpoints({
  endpoints: (builder) => ({
    getProducts: builder.query({
      query: () => ({
        url: PRODUCTS_URL,
      }),
      keepUnusedDataFor: 5, // cache the data for 5 seconds
      providesTags: ['Product'],
    }),
  }),
});

export const { useGetProductsQuery } = productsApiSlice;
