import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { getConfigValue } from '../service/configService';

export const apiSlice = createApi({
  baseQuery: async (args, api, extraOptions) => {
    const baseUrl = (await getConfigValue('REACT_APP_BASE_API_URI')) || 'http://localhost:5000'; // Fallback
    console.log('baseUrl:', baseUrl);
    const baseQuery = fetchBaseQuery({ baseUrl });
    return baseQuery(args, api, extraOptions);
  },
  tagTypes: ['Product', 'User', 'Order'],
  // eslint-disable-next-line no-unused-vars
  endpoints: (builder) => ({}),
});

export const apiSliceReducer = apiSlice.reducer;
