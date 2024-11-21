import { createSlice } from '@reduxjs/toolkit';

export const authSlice = createSlice({
  name: 'auth',
  initialState: {
    userInfo: localStorage.getItem('userInfo') ? JSON.parse(localStorage.getItem('userInfo')) : null,
  },
  reducers: {
    addUserToLocalStorage: (state, action) => {
      state.userInfo = action.payload;
      localStorage.setItem('userInfo', JSON.stringify(action.payload));
    },
    // eslint-disable-next-line no-unused-vars
    removeUserFromLocalStorage: (state, action) => {
      state.userInfo = null;
      localStorage.clear();
    },
  },
});

export const { addUserToLocalStorage, removeUserFromLocalStorage } = authSlice.actions;
export const authSliceReducer = authSlice.reducer;
