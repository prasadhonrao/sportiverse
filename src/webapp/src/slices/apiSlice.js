import { fetchBaseQuery, createApi } from '@reduxjs/toolkit/query/react';
import { getConfigValue } from '../service/configService';
import { logout } from './authSlice'; // Import the logout action

// NOTE: code here has changed to handle when our JWT and Cookie expire.
// We need to customize the baseQuery to be able to intercept any 401 responses
// and log the user out
// https://redux-toolkit.js.org/rtk-query/usage/customizing-queries#customizing-queries-with-basequery

const baseQueryWithAuth = async (args, api, extraOptions) => {
  // Get the base URL dynamically
  let baseUrl = await getConfigValue('BASE_API_URI');

  if (!baseUrl) {
    console.log('baseUrl not found');
    baseUrl = 'http://localhost:5000';
  }

  // console.log('baseUrl:', baseUrl);

  const baseQuery = fetchBaseQuery({
    baseUrl,
    credentials: 'include', // Ensure cookies are included in requests
  });

  const result = await baseQuery(args, api, extraOptions);

  // Dispatch the logout action on 401.
  if (result.error && result.error.status === 401) {
    api.dispatch(logout());
  }

  return result;
};

export const apiSlice = createApi({
  baseQuery: baseQueryWithAuth, // Use the customized baseQuery
  tagTypes: ['Product', 'Order', 'User'],
  // eslint-disable-next-line no-unused-vars
  endpoints: (builder) => ({}),
});

export const apiSliceReducer = apiSlice.reducer;
