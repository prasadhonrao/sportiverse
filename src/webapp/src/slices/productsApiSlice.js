import { PRODUCTS_URL } from '../constants';
import { apiSlice } from './apiSlice';

export const productsApiSlice = apiSlice.injectEndpoints({
  endpoints: (builder) => ({
    getProducts: builder.query({
      query: () => ({
        url: PRODUCTS_URL,
      }),
      providesTags: ['Product'],
      keepUnusedDataFor: 5,
    }),
    getProductById: builder.query({
      query: (id) => ({
        url: `${PRODUCTS_URL}/${id}`,
      }),
      providesTags: ['Product'],
      keepUnusedDataFor: 5,
    }),
  }),
});

export const { useGetProductsQuery, useGetProductByIdQuery } = productsApiSlice;
